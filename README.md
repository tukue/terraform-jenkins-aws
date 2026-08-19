# Kubernetes Application Platform on AWS

This repository provisions a Jenkins server and an application platform on AWS. The application platform reuses the existing VPC and adds an EKS cluster, managed worker nodes, a private ECR repository, and a small Helm deployment contract.

## Developer Golden Path

Any Dockerfile-based application repository can use the platform. The developer adds one small file at `platform/app.env`, then either pushes to `main` or runs one command:

```powershell
make deploy IMAGE_TAG=<unique-image-tag>
```

The command reads the platform's Terraform outputs, authenticates to ECR and EKS, builds and pushes the image, creates the application namespace, deploys with Helm, waits for the rollout, and prints the Service status. It does not run Terraform or require developers to know VPC, node, or registry details.

Start by copying [`platform/app.env.example`](platform/app.env.example) into the application repository as `platform/app.env`:

```dotenv
APP_NAME=my-api
SOURCE_PATH=..
DOCKERFILE=Dockerfile
CONTAINER_PORT=8080
HEALTH_PATH=/healthz
SERVICE_TYPE=LoadBalancer
REPLICA_COUNT=2
```

The config is intentionally language-neutral. `SOURCE_PATH` and `DOCKERFILE` are relative to `platform/app.env`; the directory must contain the application's source and Dockerfile. The application must expose `CONTAINER_PORT` and return HTTP success from `HEALTH_PATH`. [`apps/sample-api`](apps/sample-api) demonstrates the contract.

The reusable contract in [`charts/application`](charts/application) supplies the Deployment, Service, resource requests/limits, and liveness/readiness probes. A default `LoadBalancer` Service receives an AWS address; use `kubectl get service <app> -n <app>` to obtain it once provisioned.

## Prerequisites

Platform operators need Terraform >= 1.6, AWS credentials for `eu-north-1`, and values for the existing VPC/Jenkins inputs plus:

```hcl
kubernetes_version    = "<supported EKS version>"
eks_public_access_cidrs = ["<operator CIDR>/32"]
cicd_principal_arn    = "arn:aws:iam::<account-id>:role/<github-deploy-role>" # optional
```

Application developers need AWS CLI, Docker, Helm, kubectl, and Terraform available on `PATH`. Their AWS identity must have ECR push permissions and EKS access; the identity that creates the cluster is automatically an administrator.

## Provision the Platform

This is an operator action, performed before application delivery:

```bash
terraform init
terraform workspace select dev
terraform apply -var-file="terraform.tfvars"
```

The existing Terraform inputs remain required. The EKS worker nodes run in the VPC's private subnets; the added NAT gateway gives them outbound image and package access. Terraform outputs `eks_cluster_name` and `ecr_repository_url`, which deployment tooling consumes automatically.

## Deploy and Verify Locally

```powershell
make test
make deploy IMAGE_TAG=<unique-image-tag>
kubectl get pods -n sample-api
kubectl get service sample-api -n sample-api
```

If the deployment fails, `helm` reports template/configuration errors and `kubectl rollout status` returns the failed rollout. Inspect the workload with:

```bash
kubectl describe deployment sample-api -n sample-api
kubectl get events -n sample-api --sort-by=.lastTimestamp
kubectl logs deployment/sample-api -n sample-api
```

## Continuous Deployment

This repository's sample workflow tests, builds, pushes, deploys, waits for readiness, and prints Service status. Other application repositories can use the portable composite action in [`action.yml`](action.yml):

```yaml
- uses: tukue/terraform-jenkins-aws@<pinned-commit-sha>
  with:
    config-path: platform/app.env
    image-tag: ${{ github.sha }}
    aws-region: ${{ vars.AWS_REGION }}
    eks-cluster-name: ${{ vars.EKS_CLUSTER_NAME }}
    ecr-repository: ${{ vars.ECR_REPOSITORY }}
```

The calling workflow must check out application code, run its language-specific tests, and authenticate to AWS with GitHub OIDC before this action. The action then handles Docker, ECR, Kubernetes namespace creation, Helm, rollout verification, and Service status.

Before enabling it, an operator creates a GitHub OIDC-enabled IAM deployment role with ECR push permissions and supplies its ARN as the `cicd_principal_arn` Terraform input. Add that ARN as the `AWS_DEPLOY_ROLE_ARN` GitHub secret, and set `AWS_REGION`, `EKS_CLUSTER_NAME`, and `ECR_REPOSITORY` as GitHub repository variables from Terraform outputs. The Terraform EKS access entry grants that CI role cluster access; developers do not manage Kubernetes credentials.

## Platform Boundaries

- **Infrastructure:** Terraform provisions VPC, Jenkins, state storage, EKS, nodes, NAT, IAM, and ECR.
- **Platform:** Helm chart, image repository, deployment script, and CI workflow translate the application contract into Kubernetes resources.
- **Developer:** Application code, Dockerfile, health endpoint, and `platform/app.env`.

## Current Limitations

- No ingress controller, DNS automation, secret manager integration, autoscaling, or workload observability stack is provisioned yet.
- The EKS API is public and restricted by `eks_public_access_cidrs`; use narrow CIDRs.
- A `LoadBalancer` Service creates an AWS load balancer per exposed application. Add an ingress controller and shared DNS/certificate integration before operating many public services.

The legacy Jenkins EC2 path, Terraform security scan, Route 53/ACM modules, and `argocd-application.yaml` are not application delivery components. In particular, Argo CD itself is not provisioned by this repository, and that manifest is not part of the recommended path.
