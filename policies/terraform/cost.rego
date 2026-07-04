package terraform.cost

import input as tfplan

# Allowed instance types for development
allowed_instance_types = {"t3.micro", "t3.small", "t3.medium"}

deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"
    
    tags := object.get(resource.change.after, "tags", {})
    tags.Environment == "dev"
    
    instance_type := resource.change.after.instance_type
    not allowed_instance_types[instance_type]
    
    msg := sprintf("Instance '%s' in dev environment must use a cost-effective type (%s). Current: %s", [resource.address, allowed_instance_types, instance_type])
}

# Require encrypted root volumes for all instances
deny contains msg if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"
    
    device := object.get(resource.change.after, "root_block_device", [])
    count(device) > 0
    encrypted := device[0].encrypted
    not encrypted
    
    msg := sprintf("Instance '%s' must have an encrypted root volume", [resource.address])
}
