package terraform.tags

import input as tfplan

# List of required tags
required_tags = {"Environment", "Project", "Owner"}

# AWS resource types that do not support tags
non_taggable_resources = {
    "aws_security_group_rule",
    "aws_route",
    "aws_route_table_association",
    "aws_main_route_table_association",
    "aws_network_acl_rule",
    "aws_iam_role_policy",
    "aws_iam_user_policy",
    "aws_iam_group_policy",
    "aws_iam_policy_attachment",
    "aws_iam_role_policy_attachment",
}

# Check if resource has all required tags
deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    not non_taggable_resources[resource.type]
    
    tags := object.get(resource.change.after, "tags", {})
    
    missing := required_tags - {tag | tags[tag]}
    count(missing) > 0
    
    msg := sprintf("Resource '%s' is missing required tags: %s", [resource.address, missing])
}

# Check if Environment tag is valid
valid_environments = {"dev", "qa", "prod"}
deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    not non_taggable_resources[resource.type]
    
    tags := object.get(resource.change.after, "tags", {})
    env := object.get(tags, "Environment", "")
    env != ""
    not valid_environments[env]
    
    msg := sprintf("Resource '%s' has invalid Environment tag: '%s'. Must be one of: %s", [resource.address, env, valid_environments])
}
