#!/usr/bin/env bash

set -euo pipefail

export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='root'

jenkins_password="$(openssl rand -base64 24)"
jenkins_api_token="$(openssl rand -hex 20)"

echo "Waiting for Vault to be ready..."
until docker exec platform-vault vault status > /dev/null 2>&1; do
  sleep 2
done

echo "Configuring KV v2 engine..."
docker exec platform-vault vault secrets enable -path=secret kv-v2 || echo "KV engine already enabled"

echo "Writing test secret..."
docker exec platform-vault vault kv put secret/jenkins/platform/test value="super-secret-vault-value"

echo "Writing Jenkins credentials..."
docker exec platform-vault vault kv put secret/jenkins/credentials \
  username="admin" \
  password="${jenkins_password}" \
  api_token="${jenkins_api_token}"

echo "Vault configuration complete."
echo "Vault address: http://localhost:8200"
echo "Vault root token: root"
echo "Retrieve generated Jenkins credentials with:"
echo "docker exec platform-vault vault kv get secret/jenkins/credentials"
