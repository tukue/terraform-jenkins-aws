package terraform.iam_test

import data.terraform.iam

test_denies_wildcard_iam if {
    plan := {
        "resource_changes": [{
            "address": "aws_iam_policy.unsafe",
            "type": "aws_iam_policy",
            "change": {
                "after": {
                    "policy": json.marshal({
                        "Version": "2012-10-17",
                        "Statement": [{
                            "Effect": "Allow",
                            "Action": "*",
                            "Resource": "*",
                        }],
                    }),
                },
            },
        }],
    }

    violations := iam.deny with input as plan
    count(violations) == 2
}

test_allows_scoped_iam if {
    plan := {
        "resource_changes": [{
            "address": "aws_iam_policy.safe",
            "type": "aws_iam_policy",
            "change": {
                "after": {
                    "policy": json.marshal({
                        "Version": "2012-10-17",
                        "Statement": [{
                            "Effect": "Allow",
                            "Action": ["s3:GetObject"],
                            "Resource": ["arn:aws:s3:::example/*"],
                        }],
                    }),
                },
            },
        }],
    }

    violations := iam.deny with input as plan
    count(violations) == 0
}
