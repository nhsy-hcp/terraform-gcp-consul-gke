#!/bin/bash
set -euo pipefail

# Wait for TLS secret to be populated with certificate data
# Usage: wait-for-tls-secret.sh [namespace] [secret_name]

NAMESPACE="${1:-consul}"
SECRET_NAME="${2:-api-gateway-tls}"
TIMEOUT="${3:-300}"
INTERVAL=10
ELAPSED=0

echo "=========================================="
echo "Waiting for TLS Secret Certificate Data"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Secret: $SECRET_NAME"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Step 1: Check secret exists
echo "Checking if secret exists..."
WAIT_EXIST=0
while [ $WAIT_EXIST -lt 60 ]; do
  if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "✓ Secret exists"
    break
  fi
  echo "⏳ Waiting for secret to be created... (${WAIT_EXIST}s/60s)"
  sleep 5
  WAIT_EXIST=$((WAIT_EXIST + 5))
done

if [ $WAIT_EXIST -ge 60 ]; then
  echo "ERROR: Secret not created after 60s"
  exit 1
fi

# Step 2: Wait for secret to be populated with certificate data
echo ""
echo "Waiting for secret to be populated with certificate data..."
while [ $ELAPSED -lt "$TIMEOUT" ]; do
  CERT_DATA=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data.tls\.crt}' 2>/dev/null || echo "")
  KEY_DATA=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data.tls\.key}' 2>/dev/null || echo "")

  if [ -n "$CERT_DATA" ] && [ -n "$KEY_DATA" ]; then
    echo "✓ TLS secret populated with certificate data"
    echo "✓ Secret: $SECRET_NAME"
    echo ""
    echo "Certificate is ready for Gateway use"
    exit 0
  fi

  # Show progress every 30 seconds
  if [ $((ELAPSED % 30)) -eq 0 ]; then
    echo "⏳ Waiting for certificate data... (${ELAPSED}s/${TIMEOUT}s)"
  fi

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo ""
echo "=========================================="
echo "ERROR: Timeout waiting for TLS secret data"
echo "=========================================="
echo "Secret: $SECRET_NAME"
echo "Namespace: $NAMESPACE"
echo "Elapsed: ${TIMEOUT}s"
echo ""
echo "Troubleshooting:"
echo "1. Check certificate status: kubectl get certificate -n $NAMESPACE"
echo "2. Check certificate events: kubectl describe certificate -n $NAMESPACE"
echo "3. Check cert-manager logs: kubectl logs -n cert-manager -l app=cert-manager"
echo "4. Verify DNS01 challenge: kubectl get challenges -n $NAMESPACE"
exit 1
