terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
