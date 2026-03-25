#!/bin/bash
set -euo pipefail

# Wait for API Gateway load balancer IP to be assigned
# Usage: wait-for-lb-ip.sh [namespace] [timeout_seconds]

NAMESPACE="${1:-consul}"
TIMEOUT="${2:-300}"
ELAPSED=0
INTERVAL=5

echo "=========================================="
echo "Waiting for API Gateway LoadBalancer IP"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Timeout: ${TIMEOUT}s"
echo ""

while [ $ELAPSED -lt "$TIMEOUT" ]; do
  # Find the API Gateway service by label
  GATEWAY_SVC=$(kubectl get svc -n "$NAMESPACE" -l component=api-gateway -o name 2>/dev/null | head -n 1 || true)

  if [ -z "$GATEWAY_SVC" ]; then
    echo "ERROR: API Gateway service not found in namespace '$NAMESPACE'"
    echo "Expected service with label: component=api-gateway"
    echo ""
    echo "Available services in namespace:"
    kubectl get svc -n "$NAMESPACE" 2>/dev/null || echo "  (none)"
    exit 1
  fi

  # Check if external IP is assigned
  GATEWAY_IP=$(kubectl get "$GATEWAY_SVC" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

  if [ -n "$GATEWAY_IP" ]; then
    echo "✓ Gateway LoadBalancer IP assigned: $GATEWAY_IP"
    echo "✓ Service: $GATEWAY_SVC"
    echo ""
    echo "Gateway is ready for traffic routing"
    exit 0
  fi

  # Show progress
  if [ $((ELAPSED % 15)) -eq 0 ]; then
    echo "⏳ Waiting for IP assignment... (${ELAPSED}s/${TIMEOUT}s)"
  fi

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo ""
echo "=========================================="
echo "ERROR: Timeout waiting for LoadBalancer IP"
echo "=========================================="
echo "Service: $GATEWAY_SVC"
echo "Namespace: $NAMESPACE"
echo "Elapsed: ${TIMEOUT}s"
echo ""
echo "Troubleshooting:"
echo "1. Check service status: kubectl get svc -n $NAMESPACE"
echo "2. Check service events: kubectl describe svc $GATEWAY_SVC -n $NAMESPACE"
echo "3. Verify GCP quotas and permissions"
echo "4. Check GKE cluster network configuration"
exit 1
