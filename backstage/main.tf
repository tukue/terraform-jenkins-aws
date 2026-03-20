terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Uncomment after first apply to use remote backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "backstage/terraform.tfstate"
  #   region         = "your-aws-region"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "backstage-platform"
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  }
}
