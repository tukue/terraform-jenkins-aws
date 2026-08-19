package terraform.production

import input as tfplan

is_prod(resource) if {
    tags := object.get(resource.change.after, "tags", {})
    lower(object.get(tags, "Environment", "")) == "prod"
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    is_prod(resource)
    resource.type == "aws_instance"
    object.get(resource.change.after, "associate_public_ip_address", false)
    msg := sprintf("Production instance '%s' must not have a public IP address", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    is_prod(resource)
    resource.type == "aws_lb"
    not object.get(resource.change.after, "enable_deletion_protection", false)
    msg := sprintf("Production load balancer '%s' must enable deletion protection", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    is_prod(resource)
    resource.type == "aws_db_instance"
    not object.get(resource.change.after, "deletion_protection", false)
    msg := sprintf("Production database '%s' must enable deletion protection", [resource.address])
}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    is_prod(resource)
    resource.type == "aws_db_instance"
    not object.get(resource.change.after, "multi_az", false)
    msg := sprintf("Production database '%s' must use Multi-AZ", [resource.address])
}
