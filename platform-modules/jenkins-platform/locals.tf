locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      AWSRegion   = var.aws_region
      AWSAccount  = var.aws_account_id
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = var.owner
      Workspace   = var.environment
    }
  )

  effective_ec2_ami_id = trimspace(var.ec2_ami_id) != "" ? var.ec2_ami_id : data.aws_ami.latest_ubuntu.id
}
