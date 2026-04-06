#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./terraform-apply.sh [environment] [bucket_name]

Examples:
  ./terraform-apply.sh dev terraform-jenkins-aws-state-store-bucket
  ./terraform-apply.sh qa terraform-jenkins-aws-state-store-bucket
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

backend_config="backend-config-${environment}.hcl"
var_file="terraform.${environment}.tfvars"
plan_file="tfplan-${environment}"

for file in "$backend_config" "$var_file"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: required file not found: $file"
    exit 1
  fi
done

terraform init -input=false -reconfigure -backend-config="$backend_config"
terraform plan -input=false -var-file="$var_file" -var="bucket_name=$bucket_name" -out="$plan_file"
terraform apply -input=false -auto-approve "$plan_file"
