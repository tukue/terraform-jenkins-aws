# Live Environment Layout

The repository now separates reusable platform modules from live environment roots.

## Structure

```text
bootstrap/
  remote-state/       # One-time backend foundation: S3, KMS, DynamoDB locking
live/
  dev/                # Dev Jenkins platform root and backend key
  qa/                 # QA Jenkins platform root and backend key
  prod/               # Production Jenkins platform root and backend key
platform-modules/
  jenkins-platform/   # Composes network, security, compute, edge, and observability
```

## Bootstrap remote state

Create the backend once before initializing live environments:

```bash
cd bootstrap/remote-state
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The real `terraform.tfvars` file must stay local or be supplied through CI secrets.

## Plan an environment locally

```bash
make validate-live TF_ENV=dev
make provision TF_ENV=dev
```

For QA and prod, replace `TF_ENV=dev` with `qa` or `prod`.

## CI/CD model

Pull requests run formatting, linting, security scanning, and backend-free validation for every `live/*` root.

Manual workflow dispatch performs environment-specific plan or apply from the selected `live/<env>` folder. GitHub Environments should define:

- `AWS_ACCOUNT_ID` as an environment variable
- `AWS_ROLE_ARN` as an environment secret
- `JENKINS_PUBLIC_KEY` as an environment secret
- `GRAFANA_ADMIN_PASSWORD` as an environment secret when Grafana is enabled

Use required reviewers on the `qa` and `prod` GitHub Environments to enforce promotion approvals.
