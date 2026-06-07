package terraform.iam

import input as tfplan

policy_document(resource) := document if {
    raw := object.get(resource.change.after, "policy", "")
    raw != ""
    document := json.unmarshal(raw)
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type in {"aws_iam_policy", "aws_iam_role_policy"}
    document := policy_document(resource)
    statement := document.Statement[_]
    statement.Effect == "Allow"
    action := statement.Action
    is_string(action)
    action == "*"
    msg := sprintf("IAM policy '%s' must not allow wildcard actions", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type in {"aws_iam_policy", "aws_iam_role_policy"}
    document := policy_document(resource)
    statement := document.Statement[_]
    statement.Effect == "Allow"
    action := statement.Action[_]
    action == "*"
    msg := sprintf("IAM policy '%s' must not allow wildcard actions", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type in {"aws_iam_policy", "aws_iam_role_policy"}
    document := policy_document(resource)
    statement := document.Statement[_]
    statement.Effect == "Allow"
    resource_value := statement.Resource
    is_string(resource_value)
    resource_value == "*"
    msg := sprintf("IAM policy '%s' must scope resources instead of using '*'", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type in {"aws_iam_policy", "aws_iam_role_policy"}
    document := policy_document(resource)
    statement := document.Statement[_]
    statement.Effect == "Allow"
    resource_value := statement.Resource[_]
    resource_value == "*"
    msg := sprintf("IAM policy '%s' must scope resources instead of using '*'", [resource.address])
}
