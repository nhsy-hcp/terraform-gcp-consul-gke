#!/bin/bash
set -euo pipefail

# Wait for TLS secret to be populated with certificate data
# Usage: wait-for-tls-secret.sh [namespace] [secret_name]

NAMESPACE="${1:-consul}"
SECRET_NAME="${2:-api-gateway-tls}"
MAX_ATTEMPTS=30
INTERVAL=10
TIMEOUT=$((MAX_ATTEMPTS * INTERVAL))

echo "=========================================="
echo "Waiting for TLS Secret Certificate Data"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Secret: $SECRET_NAME"
echo "Timeout: ${TIMEOUT}s"
echo ""

for i in $(seq 1 $MAX_ATTEMPTS); do
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
  if [ $((i % 3)) -eq 0 ]; then
    ELAPSED=$((i * INTERVAL))
    echo "⏳ Waiting for certificate data... (${ELAPSED}s/${TIMEOUT}s)"
  fi

  sleep "$INTERVAL"
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
