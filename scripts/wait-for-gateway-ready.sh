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
  PROGRAMMED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="Programmed")].status}' 2>/dev/null || echo "Unknown")
  RESOLVED=$(kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="ResolvedRefs")].status}' 2>/dev/null || echo "Unknown")

  if [ "$PROGRAMMED" = "True" ] && [ "$RESOLVED" = "True" ]; then
    echo "✓ Gateway listener programmed and certificate references resolved"
    exit 0
  fi

  echo "Gateway status - Programmed: $PROGRAMMED, ResolvedRefs: $RESOLVED (${ELAPSED}s/${TIMEOUT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "⚠ Warning: Gateway listener not fully ready after ${TIMEOUT}s"
kubectl get gateway "$GATEWAY_NAME" -n "$NAMESPACE" -o yaml
exit 1
