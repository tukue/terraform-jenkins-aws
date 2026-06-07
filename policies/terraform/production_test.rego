package terraform.production_test

import data.terraform.production

test_denies_unprotected_production_resources if {
    plan := {
        "resource_changes": [
            {
                "address": "aws_lb.prod",
                "type": "aws_lb",
                "change": {
                    "after": {
                        "enable_deletion_protection": false,
                        "tags": {"Environment": "prod"},
                    },
                },
            },
            {
                "address": "aws_db_instance.prod",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "deletion_protection": false,
                        "multi_az": false,
                        "tags": {"Environment": "prod"},
                    },
                },
            },
        ],
    }

    violations := production.deny with input as plan
    count(violations) == 3
}

test_allows_protected_production_resources if {
    plan := {
        "resource_changes": [
            {
                "address": "aws_lb.prod",
                "type": "aws_lb",
                "change": {
                    "after": {
                        "enable_deletion_protection": true,
                        "tags": {"Environment": "prod"},
                    },
                },
            },
            {
                "address": "aws_db_instance.prod",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "deletion_protection": true,
                        "multi_az": true,
                        "tags": {"Environment": "prod"},
                    },
                },
            },
        ],
    }

    violations := production.deny with input as plan
    count(violations) == 0
}
