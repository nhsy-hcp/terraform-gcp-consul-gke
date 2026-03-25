#!/bin/bash
set -euo pipefail

# Wait for API Gateway load balancer IP to be assigned
# Usage: wait-for-lb-ip.sh [namespace] [timeout_seconds]

NAMESPACE="${1:-consul}"
TIMEOUT="${2:-600}"  # 10 minutes default
INTERVAL=10

echo "Waiting for API Gateway load balancer IP in namespace: $NAMESPACE"
echo "Timeout: ${TIMEOUT}s, Check interval: ${INTERVAL}s"

elapsed=0
while [ $elapsed -lt "$TIMEOUT" ]; do
  # Find the API Gateway service by label
  GATEWAY_SVC=$(kubectl get svc -n "$NAMESPACE" -l component=api-gateway -o name 2>/dev/null | head -n 1 || true)

  if [ -z "$GATEWAY_SVC" ]; then
    echo "Error: API Gateway service not found in namespace $NAMESPACE"
    echo "Please ensure the Helm chart has been deployed first."
    exit 1
  fi

  # Check if external IP is assigned
  GATEWAY_IP=$(kubectl get "$GATEWAY_SVC" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

  if [ -n "$GATEWAY_IP" ]; then
    echo "✓ API Gateway IP assigned: $GATEWAY_IP"
    echo "✓ Load balancer is ready for DNS record creation"
    exit 0
  fi

  echo "Waiting for IP assignment... (${elapsed}s elapsed)"
  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
done

echo "Error: Timeout waiting for API Gateway IP after ${TIMEOUT}s"
echo "The load balancer may still be provisioning. Check with: kubectl get svc -n $NAMESPACE"
exit 1
