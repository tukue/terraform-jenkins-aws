package terraform.iam

import input as tfplan

iam_policy_types = {
    "aws_iam_policy",
    "aws_iam_role_policy",
    "aws_iam_user_policy",
    "aws_iam_group_policy",
}

policy_document(resource) = document {
    raw := object.get(resource.change.after, "policy", "")
    raw != ""
    document := json.unmarshal(raw)
}

statement_action(statement, action) {
    is_string(statement.Action)
    action := statement.Action
}

statement_action(statement, action) {
    is_array(statement.Action)
    action := statement.Action[_]
}

statement_resource(statement, resource_arn) {
    is_string(statement.Resource)
    resource_arn := statement.Resource
}

statement_resource(statement, resource_arn) {
    is_array(statement.Resource)
    resource_arn := statement.Resource[_]
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy := policy_document(resource)
    statement := policy.Statement[_]
    statement_action(statement, action)
    action == "*"

    msg := sprintf("IAM policy '%s' allows Action='*'. Scope actions to the minimum required permissions.", [resource.address])
}

deny[msg] {
    resource := tfplan.resource_changes[_]
    iam_policy_types[resource.type]
    policy := policy_document(resource)
    statement := policy.Statement[_]
    statement_resource(statement, resource_arn)
    resource_arn == "*"

    msg := sprintf("IAM policy '%s' allows Resource='*'. Scope resources to specific ARNs where the AWS service supports it.", [resource.address])
}
