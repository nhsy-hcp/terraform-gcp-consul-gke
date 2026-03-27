#!/bin/bash
set -euo pipefail

# Wait for Gateway listener to be programmed and certificate references resolved
# Usage: wait-for-gateway-ready.sh [namespace] [gateway_name] [timeout_seconds]

NAMESPACE="${1:-consul}"
GATEWAY_NAME="${2:-api-gateway}"
TIMEOUT="${3:-600}"

echo "=========================================="
echo "Waiting for Gateway to be Ready"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Gateway: $GATEWAY_NAME"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Step 1: Check Gateway resource exists
echo "Checking if Gateway resource exists..."
WAIT_EXIST=0
while [ $WAIT_EXIST -lt 60 ]; do
  if kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "✓ Gateway resource exists"
    break
  fi
  echo "⏳ Waiting for Gateway resource to be created... (${WAIT_EXIST}s/60s)"
  sleep 5
  WAIT_EXIST=$((WAIT_EXIST + 5))
done

if [ $WAIT_EXIST -ge 60 ]; then
  echo "ERROR: Gateway resource not created after 60s"
  exit 1
fi

# Step 2: Wait for Gateway to be programmed
echo ""
echo "Waiting for Gateway to be programmed..."
ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt "$TIMEOUT" ]; do
  # Check Gateway-level Programmed status (not listener-level)
  GATEWAY_PROGRAMMED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}' 2>/dev/null || echo "Unknown")
  LISTENER_ACCEPTED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="Accepted")].status}' 2>/dev/null || echo "Unknown")

  if [ "$GATEWAY_PROGRAMMED" = "True" ] && [ "$LISTENER_ACCEPTED" = "True" ]; then
    echo "✓ Gateway programmed and listener accepted"
    echo "✓ Gateway: $GATEWAY_NAME"
    echo ""
    echo "Gateway is ready for HTTPRoute attachments"
    exit 0
  fi

  # Show progress every 30 seconds
  if [ $((ELAPSED % 30)) -eq 0 ]; then
    echo "⏳ Gateway status - Programmed: $GATEWAY_PROGRAMMED, Listener Accepted: $LISTENER_ACCEPTED (${ELAPSED}s/${TIMEOUT}s)"
  fi

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo ""
echo "=========================================="
echo "ERROR: Timeout waiting for Gateway readiness"
echo "=========================================="
echo "Gateway: $GATEWAY_NAME"
echo "Namespace: $NAMESPACE"
echo "Elapsed: ${TIMEOUT}s"
echo ""
echo "Gateway Status:"
kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null || echo "  (unable to retrieve)"
echo ""
echo "Troubleshooting:"
echo "1. Check gateway status: kubectl get gateway $GATEWAY_NAME -n $NAMESPACE"
echo "2. Check gateway events: kubectl describe gateway $GATEWAY_NAME -n $NAMESPACE"
echo "3. Check TLS certificate: kubectl get certificate -n $NAMESPACE"
echo "4. Check Consul API Gateway logs: kubectl logs -n $NAMESPACE -l component=api-gateway"
exit 1
