# Kubernetes Application Recommended Path

Use this path to deploy a Dockerfile-based application without managing Terraform, EKS credentials, Helm charts, Kubernetes manifests, or ECR login commands.

## One-time platform setup

The platform team provisions the target EKS cluster and ECR repository, then configures these organization or repository GitHub Actions settings for application repositories:

- `AWS_DEPLOY_ROLE_ARN` secret, trusted by GitHub OIDC and authorized for ECR push and EKS deployment
- `PLATFORM_AWS_REGION` variable
- `PLATFORM_EKS_CLUSTER_NAME` variable
- `PLATFORM_ECR_REPOSITORY` variable

For multi-Region delivery, the platform team configures `PLATFORM_DEPLOYMENT_TARGETS` as an ordered JSON array. Its first target must match the primary variables above; every additional target must point to a cluster and ECR repository receiving replicated images.

```json
[
  {
    "region": "eu-north-1",
    "eks_cluster_name": "platform-primary",
    "ecr_repository": "123456789012.dkr.ecr.eu-north-1.amazonaws.com/platform-applications",
    "replica_count": 2
  },
  {
    "region": "eu-west-1",
    "eks_cluster_name": "platform-standby",
    "ecr_repository": "123456789012.dkr.ecr.eu-west-1.amazonaws.com/platform-applications",
    "replica_count": 1
  }
]
```

The legacy `PLATFORM_STANDBY_*` variables remain supported for an existing two-Region setup, but new platform environments should use `PLATFORM_DEPLOYMENT_TARGETS`.

These settings are platform-owned. Application developers do not provide AWS credentials or infrastructure identifiers.

The platform team enables Amazon ECR Enhanced scanning with `CONTINUOUS_SCAN` once per AWS account and Region by following the [ECR Enhanced Scanning Runbook](runbooks/ecr-enhanced-scanning.md). Amazon Inspector re-scans published images as vulnerability intelligence changes; this complements the pre-push Trivy deployment gate.

Backstage also receives `PLATFORM_DEPLOYMENT_ACTION_REPOSITORY` and `PLATFORM_DEPLOYMENT_ACTION_SHA` as platform-managed configuration. The template renders these into the generated workflow; the SHA must be the full 40-character commit ID of the reviewed deployment action.

## Create an application

1. In Backstage, select **Create Kubernetes Application**.
2. Provide the application name, owning team, source path, Dockerfile path, container port, health endpoint, and repository-root test command.
3. Keep `ClusterIP` unless the service must be public. Selecting `LoadBalancer` creates an AWS load balancer.
4. Choose a GitHub repository location and create the component.

Backstage creates and registers a repository containing `platform/app.env`, `catalog-info.yaml`, a deployment workflow, and a short README.

## How the pipeline gets source code

Backstage is not in the runtime source-download path. It creates the application repository and its delivery files, then returns the repository link. Developers clone that repository, add source code and a Dockerfile, and push to `main`.

The generated workflow runs `actions/checkout`, which downloads the exact application commit that triggered the workflow. The deployment action reads `SOURCE_PATH` and `DOCKERFILE` from `platform/app.env`, then uses that checked-out directory as the Docker build context.

For an existing application repository, add the generated `platform/app.env`, `.github/workflows/deploy.yml`, and `catalog-info.yaml` files to that repository. The pipeline then checks out and builds the existing source in place.

## Provide source code and deploy

Add source code and a Dockerfile at the configured source path. The container must listen on the configured port, return HTTP success from the configured health path, and set `TEST_RUNNER` in `platform/app.env` to `npm`, `python-unittest`, `pytest`, or `go`.

```text
git push main
    -> runs the configured tests without AWS credentials
    -> GitHub Actions assumes the platform deployment role
    -> builds the image and retains a CycloneDX SBOM workflow artifact for 90 days
    -> scans the image with Trivy
    -> fails on High or Critical vulnerabilities before ECR push or EKS deployment
    -> pushes a clean, unique image to ECR
    -> creates the application namespace
    -> deploys the platform Helm chart to the primary cluster
    -> when enabled, waits for ECR replication and deploys the same image tag to every additional target
    -> waits for rollout readiness in every configured Region
    -> prints the Kubernetes Service status
```

The generated `platform/app.env` is the only deployment configuration developers normally edit. Its values are validated by the workflow and deployment action before Docker builds or Kubernetes changes occur. Existing application repositories without `TEST_RUNNER` remain compatible, but their workflows print an explicit warning and skip tests until the setting is added. Replace any legacy `TEST_COMMAND` value with an approved `TEST_RUNNER`; legacy commands fail safely rather than being executed.

Download the `sbom-<application>-<image-tag>` workflow artifact when investigating a dependency vulnerability or responding to an incident. The SBOM records the packages included in the built container image and is retained for 90 days.

## Troubleshoot

- Workflow fails before build: validate `platform/app.env` paths and the Dockerfile.
- Trivy blocks the image: update the vulnerable base image or dependency, rebuild locally, and push the remediation. High and Critical findings are a deployment gate.
- Image push fails: ask the platform team to confirm the OIDC role and ECR permissions.
- Rollout fails: inspect the workflow output, then run `kubectl describe deployment <app> -n <app>` and `kubectl get events -n <app>` using an approved platform identity.
- Service has no public address: a `LoadBalancer` service can take several minutes; use `kubectl get service <app> -n <app>` to check status.
- Standby deployment times out: confirm ECR replication includes the repository prefix and that the deployment role can describe images and access the standby EKS cluster.
