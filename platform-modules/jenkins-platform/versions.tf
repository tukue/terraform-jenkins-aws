terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"
    }
  }
}
