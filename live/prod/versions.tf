terraform {
  required_version = ">= 1.11.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"
    }
  }
}
