package terraform.tags

import input as tfplan

# List of required tags
required_tags = {"Environment", "Project", "Owner"}

# Check if resource has all required tags
deny[msg] {
    some resource
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    
    # Get tags from the planned values
    tags := resource.change.after.tags
    
    # Find missing tags
    missing := required_tags - {tag | tags[tag]}
    count(missing) > 0
    
    msg := sprintf("Resource '%s' is missing required tags: %s", [resource.address, missing])
}

# Check if Environment tag is valid
valid_environments = {"dev", "qa", "prod"}
deny[msg] {
    some resource
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"
    
    env := resource.change.after.tags.Environment
    not valid_environments[env]
    
    msg := sprintf("Resource '%s' has invalid Environment tag: '%s'. Must be one of: %s", [resource.address, env, valid_environments])
}
