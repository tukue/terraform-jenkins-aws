# Kubernetes Application Recommended Path

Use this path to deploy a Dockerfile-based application without managing Terraform, EKS credentials, Helm charts, Kubernetes manifests, or ECR login commands.

## One-time platform setup

The platform team provisions the target EKS cluster and ECR repository, then configures these organization or repository GitHub Actions settings for application repositories:

- `AWS_DEPLOY_ROLE_ARN` secret, trusted by GitHub OIDC and authorized for ECR push and EKS deployment
- `PLATFORM_AWS_REGION` variable
- `PLATFORM_EKS_CLUSTER_NAME` variable
- `PLATFORM_ECR_REPOSITORY` variable

These settings are platform-owned. Application developers do not provide AWS credentials or infrastructure identifiers.

The EKS reference provisioning root also enables Amazon ECR Enhanced scanning with `CONTINUOUS_SCAN` for every repository in its AWS account and Region. Amazon Inspector re-scans published images as vulnerability intelligence changes; this complements the pre-push Trivy deployment gate.

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

Add source code and a Dockerfile at the configured source path. The container must listen on the configured port, return HTTP success from the configured health path, and have a `TEST_COMMAND` in `platform/app.env` (for example, `npm test` or `python -m unittest discover`).

```text
git push main
    -> runs the configured tests without AWS credentials
    -> GitHub Actions assumes the platform deployment role
    -> builds the image and scans it with Trivy
    -> fails on High or Critical vulnerabilities before ECR push or EKS deployment
    -> pushes a clean, unique image to ECR
    -> creates the application namespace
    -> deploys the platform Helm chart
    -> waits for rollout readiness
    -> prints the Kubernetes Service status
```

The generated `platform/app.env` is the only deployment configuration developers normally edit. Its values are validated by the workflow and deployment action before Docker builds or Kubernetes changes occur. Existing application repositories without `TEST_COMMAND` remain compatible, but their workflows print an explicit warning and skip tests until the setting is added.

## Troubleshoot

- Workflow fails before build: validate `platform/app.env` paths and the Dockerfile.
- Trivy blocks the image: update the vulnerable base image or dependency, rebuild locally, and push the remediation. High and Critical findings are a deployment gate.
- Image push fails: ask the platform team to confirm the OIDC role and ECR permissions.
- Rollout fails: inspect the workflow output, then run `kubectl describe deployment <app> -n <app>` and `kubectl get events -n <app>` using an approved platform identity.
- Service has no public address: a `LoadBalancer` service can take several minutes; use `kubectl get service <app> -n <app>` to check status.
