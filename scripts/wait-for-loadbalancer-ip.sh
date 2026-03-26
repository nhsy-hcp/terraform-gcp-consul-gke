#!/bin/bash
set -euo pipefail

# Wait for LoadBalancer IP to be assigned

NAMESPACE="${1:-consul}"
LABEL_SELECTOR="${2:-component=api-gateway}"
TIMEOUT="${3:-300}"

echo "Waiting for LoadBalancer IP assignment (timeout ${TIMEOUT}s)..."

ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt "$TIMEOUT" ]; do
  LB_IP=$(kubectl get svc -n "$NAMESPACE" -l "$LABEL_SELECTOR" -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

  if [ -n "$LB_IP" ] && [ "$LB_IP" != "<pending>" ]; then
    echo "✓ LoadBalancer IP assigned: $LB_IP"
    echo "Waiting for DNS propagation..."
    sleep 30
    exit 0
  fi

  echo "Waiting for LoadBalancer IP... (${ELAPSED}s/${TIMEOUT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "⚠ Warning: LoadBalancer IP not assigned after ${TIMEOUT}s"
exit 1
