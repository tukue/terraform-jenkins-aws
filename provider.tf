provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile != "" ? var.aws_profile : null
  allowed_account_ids = var.aws_account_id != "" ? [var.aws_account_id] : null
}
