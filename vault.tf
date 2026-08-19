variable "enable_vault_integration" {
  description = "Enable a Vault-backed secret lookup for integration testing"
  type        = bool
  default     = false
}

variable "vault_address" {
  description = "Vault server address, for example https://vault.example.com"
  type        = string
  default     = ""
}

variable "vault_token" {
  description = "Vault token for integration testing"
  type        = string
  default     = ""
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
  default     = ""
}

variable "vault_secret_key" {
  description = "Key inside the Vault secret data to read"
  type        = string
  default     = "value"
}

provider "vault" {
  address         = var.vault_address != "" ? var.vault_address : null
  token           = var.vault_token != "" ? var.vault_token : null
  namespace       = var.vault_namespace != "" ? var.vault_namespace : null
  skip_tls_verify = var.vault_skip_tls_verify
}

data "vault_kv_secret_v2" "vault_test" {
  count = var.enable_vault_integration && var.vault_secret_path != "" ? 1 : 0

  mount = var.vault_kv_mount
  name  = var.vault_secret_path
}

locals {
  vault_test_secret_value = var.enable_vault_integration && var.vault_secret_path != "" ? try(data.vault_kv_secret_v2.vault_test[0].data[var.vault_secret_key], null) : null
}
