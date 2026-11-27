#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Building Polaris Microservices Images for Minikube"
echo "=========================================================="

SERVICES=(
  "auth-service"
  "catalog-service"
  "equipment-service"
  "observation-service"
  "quest-service"
  "verification-service"
  "weather-service"
)

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SERVICES_DIR="${BASE_DIR}/polaris-microservices/services"

for svc in "${SERVICES[@]}"; do
  tag="polaris/${svc}:latest"
  echo ""
  echo ">>> Building ${tag} from ${SERVICES_DIR}/${svc} ..."
  minikube image build -t "${tag}" "${SERVICES_DIR}/${svc}"
  echo "Successfully built ${tag}"
done

echo ""
echo "All 7 microservice images built and cached in Minikube!"
