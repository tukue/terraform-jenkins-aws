terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  alias               = "primary"
  region              = var.primary_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
}

provider "aws" {
  alias               = "standby"
  region              = var.standby_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
}
