#!/bin/bash
set -euo pipefail

# Wait for TLS secret to be populated with certificate data

NAMESPACE="${1:-consul}"
SECRET_NAME="${2:-api-gateway-tls}"
MAX_ATTEMPTS=30
INTERVAL=10

echo "Verifying TLS secret contains certificate data..."

for i in $(seq 1 $MAX_ATTEMPTS); do
  CERT_DATA=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data.tls\.crt}' 2>/dev/null || echo "")
  KEY_DATA=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data.tls\.key}' 2>/dev/null || echo "")

  if [ -n "$CERT_DATA" ] && [ -n "$KEY_DATA" ]; then
    echo "✓ TLS secret populated with certificate data"
    exit 0
  fi

  if [ "$i" -eq "$MAX_ATTEMPTS" ]; then
    echo "⚠ Warning: TLS secret not populated after $((MAX_ATTEMPTS * INTERVAL))s"
    exit 1
  fi

  echo "Waiting for TLS secret data... ($i/$MAX_ATTEMPTS)"
  sleep "$INTERVAL"
done
