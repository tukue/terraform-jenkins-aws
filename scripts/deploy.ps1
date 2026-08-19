param(
    [Parameter(Mandatory = $true)]
    [string]$ImageTag,
    [string]$ConfigPath = "apps/sample-api/platform/app.env",
    [Parameter(Mandatory = $true)]
    [string]$Region,
    [Parameter(Mandatory = $true)]
    [string]$ClusterName,
    [Parameter(Mandatory = $true)]
    [string]$Repository
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repositoryRoot

try {
    foreach ($command in @("aws", "docker", "helm", "kubectl")) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            throw "Required command '$command' was not found on PATH."
        }
    }

    $config = @{}
    foreach ($line in Get-Content -LiteralPath $ConfigPath) {
        if ($line -match '^\s*([A-Z_]+)\s*=\s*(.*?)\s*$') {
            $config[$matches[1]] = $matches[2]
        }
    }

    foreach ($key in @("APP_NAME", "SOURCE_PATH", "DOCKERFILE", "CONTAINER_PORT", "HEALTH_PATH", "SERVICE_TYPE")) {
        if (-not $config.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($config[$key])) {
            throw "Missing $key in $ConfigPath. Start from platform/app.env.example."
        }
    }

    $appName = $config.APP_NAME
    if ($appName -notmatch '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$') {
        throw "APP_NAME must be a valid Kubernetes name."
    }
    if ($config.CONTAINER_PORT -notmatch '^\d+$') { throw "CONTAINER_PORT must be numeric." }
    if ($config.HEALTH_PATH -notmatch '^/') { throw "HEALTH_PATH must start with '/'." }
    if ($config.SERVICE_TYPE -notin @("ClusterIP", "LoadBalancer")) { throw "SERVICE_TYPE must be ClusterIP or LoadBalancer." }

    $configDirectory = Split-Path -Parent (Resolve-Path -LiteralPath $ConfigPath)
    $appPath = Join-Path $configDirectory $config.SOURCE_PATH
    $dockerfile = Join-Path $appPath $config.DOCKERFILE
    if (-not (Test-Path -LiteralPath $dockerfile)) { throw "Dockerfile not found: $dockerfile" }

    $registry = $repository.Split('/')[0]
    $imageTag = "$appName-$ImageTag"
    $image = "$repository`:$imageTag"

    aws eks update-kubeconfig --region $region --name $clusterName | Out-Host
    aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $registry | Out-Host
    docker build --file $dockerfile --tag $image $appPath | Out-Host
    docker push $image | Out-Host

    $helmArguments = @("upgrade", "--install", $appName, "charts/application", "--namespace", $appName, "--create-namespace", "--wait", "--timeout", "10m", "--set", "image.repository=$repository", "--set", "image.tag=$imageTag", "--set", "containerPort=$($config.CONTAINER_PORT)", "--set", "health.path=$($config.HEALTH_PATH)", "--set", "service.type=$($config.SERVICE_TYPE)")
    if ($config.ContainsKey("REPLICA_COUNT")) { $helmArguments += @("--set", "replicaCount=$($config.REPLICA_COUNT)") }
    & helm @helmArguments | Out-Host
    kubectl rollout status "deployment/$appName" --namespace $appName --timeout=5m | Out-Host
    kubectl get service $appName --namespace $appName --output wide
} finally {
    Pop-Location
}
