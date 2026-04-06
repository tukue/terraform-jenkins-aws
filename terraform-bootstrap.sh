#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./terraform-bootstrap.sh [environment] [bucket_name]

Examples:
  ./terraform-bootstrap.sh dev terraform-jenkins-aws-state-store-bucket
EOF
}

environment="${1:-dev}"
bucket_name="${2:-}"

case "$environment" in
  dev|qa|prod) ;;
  *)
    echo "Error: environment must be one of dev, qa, or prod"
    usage
    exit 1
    ;;
esac

if [[ -z "$bucket_name" ]]; then
  echo "Error: missing bucket_name"
  usage
  exit 1
fi

var_file="terraform.${environment}.tfvars"

if [[ ! -f "$var_file" ]]; then
  echo "Error: required file not found: $var_file"
  exit 1
fi

terraform init -backend=false -input=false
terraform apply -input=false -auto-approve -var-file="$var_file" -var="bucket_name=$bucket_name" \
  -target=aws_kms_key.terraform_encryption_key \
  -target=aws_kms_alias.terraform_encryption_key \
  -target=aws_s3_bucket.terraform_state \
  -target=aws_s3_bucket_versioning.terraform_state \
  -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state \
  -target=aws_s3_bucket_public_access_block.terraform_state \
  -target=aws_dynamodb_table.terraform_locks
