# PowerShell script for scanning Terraform code using Terrascan
# Usage: .\scan-terraform.ps1 [directory]

param (
    [Parameter(Mandatory=$false)]
    [string]$ScanDir = "."  # Default to current directory if not specified
)

# Check if Terrascan is installed
$terrascanInstalled = $null
try {
    $terrascanInstalled = Get-Command terrascan -ErrorAction SilentlyContinue
} catch {
    # Command not found
}

if ($null -eq $terrascanInstalled) {
    Write-Host "Terrascan not found. Installing..."
    
    # Create a temporary directory
    $tempDir = Join-Path $env:TEMP "terrascan-install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Get the latest release URL
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/accurics/terrascan/releases/latest"
    $downloadUrl = $latestRelease.assets | Where-Object { $_.name -like "*Windows_x86_64.zip" } | Select-Object -ExpandProperty browser_download_url
    
    # Download and extract Terrascan
    $zipPath = Join-Path $tempDir "terrascan.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    
    # Add to PATH
    $terrascanPath = Join-Path $tempDir "terrascan.exe"
    $env:Path += ";$tempDir"
    
    Write-Host "Terrascan installed temporarily for this session"
} else {
    Write-Host "Terrascan is already installed"
}

# Run Terrascan on the specified directory
Write-Host "Scanning Terraform code in $ScanDir..."
terrascan scan -d $ScanDir -o human

# Save results to a file
Write-Host "Saving scan results to terrascan-results.json"
$scanResults = terrascan scan -d $ScanDir -o json
$scanResults | Out-File -FilePath "terrascan-results.json"

# Parse the JSON results
$resultsJson = $scanResults | ConvertFrom-Json
$highCount = ($resultsJson.violations | Where-Object { $_.severity -eq "HIGH" }).Count
$mediumCount = ($resultsJson.violations | Where-Object { $_.severity -eq "MEDIUM" }).Count
$lowCount = ($resultsJson.violations | Where-Object { $_.severity -eq "LOW" }).Count

# Display summary
Write-Host "Summary of violations:"
Write-Host "HIGH: $highCount"
Write-Host "MEDIUM: $mediumCount"
Write-Host "LOW: $lowCount"

# Exit with error code if high severity issues found
if ($highCount -gt 0) {
    Write-Host "WARNING: High severity issues found!" -ForegroundColor Red
    exit 1
}

Write-Host "Scan completed successfully" -ForegroundColor Green