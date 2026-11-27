# Deploy Polaris Microservices to Kubernetes / Minikube
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Polaris to Kubernetes (namespace: polaris)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$k8sDir = Join-Path (Split-Path -Parent $PSScriptRoot) "k8s"

kubectl apply -k $k8sDir

Write-Host "`nWaiting for deployments to roll out..." -ForegroundColor Yellow
kubectl rollout status deployment/postgres -n polaris --timeout=90s
kubectl rollout status deployment/rabbitmq -n polaris --timeout=90s
kubectl rollout status deployment/gateway -n polaris --timeout=90s

Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
Write-Host "Run .\demo.ps1 to verify the deployment." -ForegroundColor Cyan
