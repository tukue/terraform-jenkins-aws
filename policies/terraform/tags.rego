package terraform.tags

import input as tfplan

# List of required tags
required_tags = {"Environment", "Project", "Owner"}

# Check if resource has all required tags
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    
    tags := object.get(resource.change.after, "tags", {})
    
    missing := required_tags - {tag | tags[tag]}
    count(missing) > 0
    
    msg := sprintf("Resource '%s' is missing required tags: %s", [resource.address, missing])
}

# Check if Environment tag is valid
valid_environments = {"dev", "qa", "prod"}
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    
    tags := object.get(resource.change.after, "tags", {})
    env := object.get(tags, "Environment", "")
    env != ""
    not valid_environments[env]
    
    msg := sprintf("Resource '%s' has invalid Environment tag: '%s'. Must be one of: %s", [resource.address, env, valid_environments])
}
