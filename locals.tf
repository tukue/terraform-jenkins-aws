locals {
  # Common tags to be assigned to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      AWSRegion   = var.aws_region
      AWSAccount  = var.aws_account_id
      Project     = "Jenkins-AWS"
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
      Workspace   = var.environment
    }
  )
}
