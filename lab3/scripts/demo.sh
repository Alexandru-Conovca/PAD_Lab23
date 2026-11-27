#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Polaris Kubernetes Demonstration (Lab 3 Defense)"
echo "=========================================================="

echo ""
echo "--- [1/7] All Pods (kubectl get pods -n polaris) ---"
kubectl get pods -n polaris -o wide

echo ""
echo "--- [2/7] All Services (kubectl get services -n polaris) ---"
kubectl get services -n polaris

echo ""
echo "--- [3/7] All Deployments (kubectl get deployments -n polaris) ---"
kubectl get deployments -n polaris

echo ""
echo "--- [4/7] Structured JSON Logs (Catalog Service) ---"
kubectl logs -l app=catalog-service -n polaris --tail=10

echo ""
echo "--- [5/7] API Health Check via Gateway Pod ---"
GATEWAY_POD=$(kubectl get pods -n polaris -l app=gateway -o jsonpath="{.items[0].metadata.name}")
if [ -n "$GATEWAY_POD" ]; then
    echo "Pinging API Gateway ping endpoint..."
    kubectl exec -n polaris "$GATEWAY_POD" -- wget -qO- http://localhost:80/ping
    echo ""
    echo "Pinging Catalog Service via internal Kubernetes DNS..."
    kubectl exec -n polaris "$GATEWAY_POD" -- wget -qO- http://catalog-service:8002/health
    echo ""
fi

echo ""
echo "--- [6/7] Horizontal Pod Scaling Demonstration ---"
echo "Scaling catalog-service from 2 to 3 replicas..."
kubectl scale deployment catalog-service --replicas=3 -n polaris
sleep 3
kubectl get pods -l app=catalog-service -n polaris

echo ""
echo "--- [7/7] Self-Healing / Pod Recovery Demonstration ---"
TARGET_POD=$(kubectl get pods -n polaris -l app=auth-service -o jsonpath="{.items[0].metadata.name}")
echo "Deleting pod ${TARGET_POD} to simulate failure..."
kubectl delete pod "$TARGET_POD" -n polaris --now
sleep 2
echo "Kubernetes automatically replaces the deleted pod:"
kubectl get pods -l app=auth-service -n polaris

echo ""
echo "=========================================================="
echo " All 7 Laboratory Demonstration Criteria Complete! "
echo "=========================================================="
