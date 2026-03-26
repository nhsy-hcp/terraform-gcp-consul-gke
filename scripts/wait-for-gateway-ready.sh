#!/bin/bash
set -euo pipefail

# Wait for Gateway listener to be programmed and certificate references resolved

NAMESPACE="${1:-consul}"
GATEWAY_NAME="${2:-api-gateway}"
TIMEOUT="${3:-600}"

echo "Waiting for Gateway listener to be programmed (timeout ${TIMEOUT}s)..."

ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt "$TIMEOUT" ]; do
  # Check Gateway-level Programmed status (not listener-level)
  GATEWAY_PROGRAMMED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}' 2>/dev/null || echo "Unknown")
  LISTENER_ACCEPTED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="Accepted")].status}' 2>/dev/null || echo "Unknown")

  if [ "$GATEWAY_PROGRAMMED" = "True" ] && [ "$LISTENER_ACCEPTED" = "True" ]; then
    echo "✓ Gateway programmed and listener accepted"
    exit 0
  fi

  echo "Gateway status - Programmed: $GATEWAY_PROGRAMMED, Listener Accepted: $LISTENER_ACCEPTED (${ELAPSED}s/${TIMEOUT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "⚠ Warning: Gateway listener not fully ready after ${TIMEOUT}s"
kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o yaml
exit 1
