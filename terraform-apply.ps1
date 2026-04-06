param(
  [ValidateSet('dev', 'qa', 'prod')]
  [string]$Environment = 'dev',

  [Parameter(Mandatory = $true)]
  [string]$BucketName,

  [switch]$SkipInit
)

$ErrorActionPreference = 'Stop'

$backendConfig = "backend-config-$Environment.hcl"
$varFile = "terraform.$Environment.tfvars"

foreach ($file in @($backendConfig, $varFile)) {
  if (-not (Test-Path -LiteralPath $file)) {
    throw "Required file not found: $file"
  }
}

if (-not $SkipInit) {
  terraform init -input=false -reconfigure "-backend-config=$backendConfig"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

terraform plan -input=false "-var-file=$varFile" "-var=bucket_name=$BucketName" "-out=tfplan-$Environment"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

terraform apply -input=false -auto-approve "tfplan-$Environment"
exit $LASTEXITCODE
