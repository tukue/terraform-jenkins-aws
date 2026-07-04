locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = "Jenkins-AWS"
      ManagedBy   = "Terraform"
      Owner       = "platform-team"
      Purpose     = "terraform-state"
    }
  )
}
