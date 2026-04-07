package terraform.networking

import input as tfplan

# Deny security group rules that allow ingress from 0.0.0.0/0 on sensitive ports
sensitive_ports = {22, 3389, 5432, 27017, 6379}

deny[msg] {
    some resource
    resource := tfplan.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.type == "ingress"
    
    # Check if the port is sensitive
    port := resource.change.after.from_port
    sensitive_ports[port]
    
    # Check if cidr_blocks includes 0.0.0.0/0
    some cidr
    cidr := resource.change.after.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    
    msg := sprintf("Security group rule '%s' allows ingress from 0.0.0.0/0 on sensitive port %d", [resource.address, port])
}

# Ensure security group has a non-default description
deny[msg] {
    some resource
    resource := tfplan.resource_changes[_]
    resource.type == "aws_security_group"
    
    desc := resource.change.after.description
    (desc == "Managed by Terraform") # Terraform's default description
    
    msg := sprintf("Security group '%s' must have a descriptive, non-default description", [resource.address])
}
