# Script to demonstrate all 7 criteria required by Section 14 of promt3.md
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Polaris Kubernetes Demonstration (Lab 3 Defense)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. All Pods
Write-Host "`n--- [1/7] All Pods (kubectl get pods -n polaris) ---" -ForegroundColor Yellow
kubectl get pods -n polaris -o wide

# 2. All Services
Write-Host "`n--- [2/7] All Services (kubectl get services -n polaris) ---" -ForegroundColor Yellow
kubectl get services -n polaris

# 3. All Deployments
Write-Host "`n--- [3/7] All Deployments (kubectl get deployments -n polaris) ---" -ForegroundColor Yellow
kubectl get deployments -n polaris

# 4. Logs Inspection
Write-Host "`n--- [4/7] Structured JSON Logs (Catalog Service) ---" -ForegroundColor Yellow
kubectl logs -l app=catalog-service -n polaris --tail=10

# 5. API Testing
Write-Host "`n--- [5/7] API Health Check via Gateway Pod ---" -ForegroundColor Yellow
$gatewayPod = (kubectl get pods -n polaris -l app=gateway -o jsonpath="{.items[0].metadata.name}")
if ($gatewayPod) {
    Write-Host "Pinging API through Gateway pod: $gatewayPod ..."
    kubectl exec -n polaris $gatewayPod -- wget -qO- http://localhost:80/ping
    Write-Host "`nPing Catalog through internal DNS: ..."
    kubectl exec -n polaris $gatewayPod -- wget -qO- http://catalog-service:8002/health
}

# 6. Horizontal Pod Scaling
Write-Host "`n--- [6/7] Horizontal Pod Scaling Demonstration ---" -ForegroundColor Yellow
Write-Host "Scaling catalog-service from 2 to 3 replicas..." -ForegroundColor Cyan
kubectl scale deployment catalog-service --replicas=3 -n polaris
Start-Sleep -Seconds 3
kubectl get pods -l app=catalog-service -n polaris

# 7. Self-healing / Automatic Recovery
Write-Host "`n--- [7/7] Self-Healing / Pod Recovery Demonstration ---" -ForegroundColor Yellow
$targetPod = (kubectl get pods -n polaris -l app=auth-service -o jsonpath="{.items[0].metadata.name}")
Write-Host "Simulating failure by deleting pod: $targetPod ..." -ForegroundColor Magenta
kubectl delete pod $targetPod -n polaris --now
Start-Sleep -Seconds 2
Write-Host "Checking pods: Kubernetes automatically recreates replacement pod:" -ForegroundColor Green
kubectl get pods -l app=auth-service -n polaris

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " All 7 Laboratory Demonstration Criteria Complete! " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
