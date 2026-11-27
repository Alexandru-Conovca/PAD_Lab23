# PowerShell script to build all 7 Polaris microservices directly inside Minikube
param (
    [string]$MinikubePath = "C:\Program Files\Kubernetes\Minikube\minikube.exe"
)

$services = @(
    "auth-service",
    "catalog-service",
    "equipment-service",
    "observation-service",
    "quest-service",
    "verification-service",
    "weather-service"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Building Polaris Microservices Images for Minikube" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$baseDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$servicesDir = Join-Path $baseDir "polaris-microservices\services"

foreach ($svc in $services) {
    $svcPath = Join-Path $servicesDir $svc
    $tag = "polaris/$svc`:latest"
    Write-Host "`n>>> Building $tag from $svcPath ..." -ForegroundColor Yellow
    
    if (Test-Path $MinikubePath) {
        & $MinikubePath image build -t $tag $svcPath
    } else {
        minikube image build -t $tag $svcPath
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to build $tag" -ForegroundColor Red
        exit 1
    }
    Write-Host "Successfully built $tag" -ForegroundColor Green
}

Write-Host "`nAll 7 microservice images built and cached in Minikube!" -ForegroundColor Green
