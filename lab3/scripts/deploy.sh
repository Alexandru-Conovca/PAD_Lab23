#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Deploying Polaris to Kubernetes (namespace: polaris)"
echo "=========================================================="

K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../k8s" && pwd)"

kubectl apply -k "${K8S_DIR}"

echo ""
echo "Waiting for deployments to roll out..."
kubectl rollout status deployment/postgres -n polaris --timeout=90s
kubectl rollout status deployment/rabbitmq -n polaris --timeout=90s
kubectl rollout status deployment/gateway -n polaris --timeout=90s

echo ""
echo "Deployment completed successfully!"
echo "Run ./demo.sh to verify the deployment."
