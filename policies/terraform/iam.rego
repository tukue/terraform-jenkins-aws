package terraform.iam

import input as tfplan

iam_policy_types = {
    "aws_iam_policy",
    "aws_iam_role_policy",
    "aws_iam_user_policy",
    "aws_iam_group_policy",
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy_json := object.get(resource.change.after, "policy", "")
    policy_json != ""
    policy := json.unmarshal(policy_json)
    statement := policy.Statement[_]
    action := statement.Action
    action == "*"

    msg := sprintf("IAM policy '%s' allows Action='*'. Scope actions to the minimum required permissions.", [resource.address])
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy_json := object.get(resource.change.after, "policy", "")
    policy_json != ""
    policy := json.unmarshal(policy_json)
    statement := policy.Statement[_]
    action := statement.Action[_]
    action == "*"

    msg := sprintf("IAM policy '%s' allows Action='*'. Scope actions to the minimum required permissions.", [resource.address])
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy_json := object.get(resource.change.after, "policy", "")
    policy_json != ""
    policy := json.unmarshal(policy_json)
    statement := policy.Statement[_]
    resource_arn := statement.Resource
    resource_arn == "*"

    msg := sprintf("IAM policy '%s' allows Resource='*'. Scope resources to specific ARNs where the AWS service supports it.", [resource.address])
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy_json := object.get(resource.change.after, "policy", "")
    policy_json != ""
    policy := json.unmarshal(policy_json)
    statement := policy.Statement[_]
    resource_arn := statement.Resource[_]
    resource_arn == "*"

    msg := sprintf("IAM policy '%s' allows Resource='*'. Scope resources to specific ARNs where the AWS service supports it.", [resource.address])
}
