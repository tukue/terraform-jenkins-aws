# Platform Vault Service

This directory provides a functional local Vault instance for secret management. It uses Docker Compose to run Vault in development mode, pre-configured with a root token and KV v2 engine.

## Quick Start

1. **Start the Vault stack:**
   ```bash
   docker compose up -d
   ```

2. **Run the setup script:**
   This will initialize the KV engine and store test secrets.
   ```bash
   bash setup-vault.sh
   ```

3. **Verify Vault:**
   - Address: [http://localhost:8200](http://localhost:8200)
   - Root Token: `root`

## Terraform Integration

To use this local Vault with the platform's Terraform, configure the following variables in your `terraform.tfvars`:

```hcl
enable_vault_integration = true
vault_address            = "http://localhost:8200"
vault_token              = "root"
vault_secret_path        = "jenkins/platform/test"
vault_secret_key         = "value"
```

## Secret Layout

The setup script creates the following secrets:

- `secret/jenkins/platform/test`: `value="super-secret-vault-value"`
- `secret/jenkins/credentials`: `username`, `password`, `api_token`

## Advanced Configuration

For production-like scenarios, you can use the `vault-local-test/` directory to test more complex policies and authentication methods.

## Benefits

- **Secure by Default**: Avoid storing secrets in plaintext `tfvars` files.
- **Dynamic Secrets**: Potential for dynamic AWS credentials in the future.
- **Centralized Management**: One place to audit and rotate all platform secrets.
