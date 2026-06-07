package terraform.cost

import input as tfplan

# Allowed instance types by environment
allowed_instance_types_dev = {"t3.micro", "t3.small", "t3.medium", "t3.large"}
allowed_instance_types_qa = {"t3.small", "t3.medium", "t3.large", "t3.xlarge"}
allowed_instance_types_prod = {"t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge"}

# Deny cost-ineffective instances in dev
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"

    tags := object.get(resource.change.after, "tags", {})
    env := lower(object.get(tags, "Environment", "dev"))

    env == "dev"
    instance_type := resource.change.after.instance_type
    not allowed_instance_types_dev[instance_type]

    msg := sprintf("Dev instance '%s' uses expensive type '%s'. Allowed: %v", [resource.address, instance_type, allowed_instance_types_dev])
}

# Deny cost-ineffective instances in qa
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"

    tags := object.get(resource.change.after, "tags", {})
    env := lower(object.get(tags, "Environment", "qa"))

    env == "qa"
    instance_type := resource.change.after.instance_type
    not allowed_instance_types_qa[instance_type]

    msg := sprintf("QA instance '%s' uses type '%s' outside allowed range. Allowed: %v", [resource.address, instance_type, allowed_instance_types_qa])
}

# Require encrypted root volumes
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"

    device := object.get(resource.change.after, "root_block_device", [])
    count(device) > 0
    encrypted := device[0].encrypted
    not encrypted

    msg := sprintf("Instance '%s' must have an encrypted root volume (add root_block_device with encrypted = true)", [resource.address])
}

# Deny gp2 volumes in production (require gp3 for cost/performance)
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_ebs_volume"

    tags := object.get(resource.change.after, "tags", {})
    env := lower(object.get(tags, "Environment", "dev"))

    env == "prod"
    resource.change.after.type == "gp2"

    msg := sprintf("Prod EBS volume '%s' uses gp2. Migrate to gp3 for better cost/performance", [resource.address])
}

# Require delete protection on RDS in production
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_db_instance"

    tags := object.get(resource.change.after, "tags", {})
    env := lower(object.get(tags, "Environment", "dev"))

    env == "prod"
    resource.change.after.delete_protection != true

    msg := sprintf("Production RDS '%s' must have deletion protection enabled", [resource.address])
}

# Enforce cost tags on all billable resources
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.mode == "managed"

    billable_types := {"aws_instance", "aws_db_instance", "aws_lb", "aws_nat_gateway", "aws_eip"}
    resource.type == billable_types[_]

    tags := object.get(resource.change.after, "tags", {})
    not object.get(tags, "CostCenter", false)

    msg := sprintf("Billable resource '%s' is missing CostCenter tag", [resource.address])
}
