terraform {
  required_version = ">= 1.0.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

variable "vault_address" {
  description = "Vault server address"
  type        = string
}

variable "vault_token" {
  description = "Vault token"
  type        = string
  sensitive   = true
}

variable "vault_namespace" {
  description = "Optional Vault namespace"
  type        = string
  default     = ""
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS verification when connecting to Vault"
  type        = bool
  default     = false
}

variable "vault_kv_mount" {
  description = "KV v2 mount name in Vault"
  type        = string
  default     = "secret"
}

variable "vault_secret_path" {
  description = "Path to the KV v2 secret to read"
  type        = string
}

variable "vault_secret_key" {
  description = "Key inside the Vault secret data to read"
  type        = string
  default     = "value"
}

provider "vault" {
  address         = var.vault_address
  token           = var.vault_token
  namespace       = var.vault_namespace != "" ? var.vault_namespace : null
  skip_tls_verify = var.vault_skip_tls_verify
}

data "vault_kv_secret_v2" "test" {
  mount = var.vault_kv_mount
  name  = var.vault_secret_path
}

output "vault_test_secret_value" {
  value     = try(data.vault_kv_secret_v2.test.data[var.vault_secret_key], null)
  sensitive = true
}
