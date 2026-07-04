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
