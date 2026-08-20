package terraform.iam

import input as tfplan

iam_policy_types = {
    "aws_iam_policy",
    "aws_iam_role_policy",
    "aws_iam_user_policy",
    "aws_iam_group_policy",
}

policy_document(resource) = document if {
    raw := object.get(resource.change.after, "policy", "")
    raw != ""
    document := json.unmarshal(raw)
}

statement_actions(statement) := statement.Action if {
    is_array(statement.Action)
} else := [statement.Action] if {
    is_string(statement.Action)
} else := []

statement_resources(statement) := statement.Resource if {
    is_array(statement.Resource)
} else := [statement.Resource] if {
    is_string(statement.Resource)
} else := []

deny contains msg if {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy := policy_document(resource)
    statement := policy.Statement[_]
    action := statement_actions(statement)[_]
    action == "*"

    msg := sprintf("IAM policy '%s' allows Action='*'. Scope actions to the minimum required permissions.", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy := policy_document(resource)
    statement := policy.Statement[_]
    resource_arn := statement_resources(statement)[_]
    resource_arn == "*"

    msg := sprintf("IAM policy '%s' allows Resource='*'. Scope resources to specific ARNs where the AWS service supports it.", [resource.address])
}
