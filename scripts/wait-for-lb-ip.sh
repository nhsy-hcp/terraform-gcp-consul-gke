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

# First, wait for the Gateway resource to exist (created by Helm)
echo "Checking for Gateway resource..."
GATEWAY_WAIT=0
while [ $GATEWAY_WAIT -lt 60 ]; do
  if kubectl get gateway api-gateway -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "✓ Gateway resource exists"
    break
  fi
  echo "⏳ Waiting for Gateway resource to be created... (${GATEWAY_WAIT}s/60s)"
  sleep 5
  GATEWAY_WAIT=$((GATEWAY_WAIT + 5))
done

if [ $GATEWAY_WAIT -ge 60 ]; then
  echo "ERROR: Gateway resource not created after 60s"
  exit 1
fi

# Now wait for the service to be created by Consul API Gateway controller
echo ""
echo "Waiting for API Gateway service to be created by controller..."
while [ $ELAPSED -lt "$TIMEOUT" ]; do
  # Find the API Gateway service by label
  GATEWAY_SVC=$(kubectl get svc -n "$NAMESPACE" -l component=api-gateway -o name 2>/dev/null | head -n 1 || true)

  if [ -n "$GATEWAY_SVC" ]; then
    echo "✓ API Gateway service created: $GATEWAY_SVC"
    break
  fi

  if [ $((ELAPSED % 15)) -eq 0 ]; then
    echo "⏳ Waiting for service creation... (${ELAPSED}s/${TIMEOUT}s)"
  fi

  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

if [ -z "$GATEWAY_SVC" ]; then
  echo ""
  echo "=========================================="
  echo "ERROR: API Gateway service not created"
  echo "=========================================="
  echo "Namespace: $NAMESPACE"
  echo "Elapsed: ${TIMEOUT}s"
  echo ""
  echo "Available services in namespace:"
  kubectl get svc -n "$NAMESPACE" 2>/dev/null || echo "  (none)"
  echo ""
  echo "Troubleshooting:"
  echo "1. Check Gateway status: kubectl get gateway api-gateway -n $NAMESPACE"
  echo "2. Check Consul API Gateway controller logs"
  exit 1
fi

# Reset elapsed for IP wait
ELAPSED=0
echo ""
echo "Waiting for LoadBalancer IP assignment..."
while [ $ELAPSED -lt "$TIMEOUT" ]; do

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
