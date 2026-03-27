#!/bin/bash
set -euo pipefail

# Wait for a Certificate resource to be Ready
# Usage: wait-for-certificate.sh [namespace] [certificate_name] [timeout_seconds]

NAMESPACE="${1:-consul}"
CERT_NAME="${2:-api-gateway-cert}"
TIMEOUT="${3:-300}"

echo "=========================================="
echo "Waiting for TLS Certificate Ready"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Certificate: $CERT_NAME"
echo "Timeout: ${TIMEOUT}s"
echo ""

ELAPSED=0
INTERVAL=10

# Step 1: Wait for resource to exist (to handle race conditions)
echo "Checking if certificate resource exists..."
while [ $ELAPSED -lt 60 ]; do
  if kubectl get certificate "$CERT_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "✓ Certificate resource $CERT_NAME found"
    break
  fi
  echo "⏳ Waiting for certificate resource $CERT_NAME to be created... (${ELAPSED}s/60s)"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge 60 ] && ! kubectl get certificate "$CERT_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Certificate $CERT_NAME not found after 60s"
  exit 1
fi

# Reset elapsed for the actual wait
ELAPSED=0

# Step 2: Wait for condition Ready=True
echo "Waiting for certificate to be issued and ready..."
while [ $ELAPSED -lt "$TIMEOUT" ]; do
  # Use kubectl wait but wrap it to catch transient errors like 'BadRequest'
  if kubectl wait --for=condition=ready certificate/"$CERT_NAME" -n "$NAMESPACE" --timeout=30s 2>/dev/null; then
    echo "✓ TLS certificate is ready"
    exit 0
  fi

  # Check if there's a permanent failure
  STATUS=$(kubectl get certificate "$CERT_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
  MESSAGE=$(kubectl get certificate "$CERT_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' 2>/dev/null || echo "No message")

  if [ "$STATUS" = "False" ] && [[ "$MESSAGE" == *"Failed"* || "$MESSAGE" == *"Error"* ]]; then
    echo "⚠ Certificate reported a failure: $MESSAGE"
  fi

  # Show progress every 30 seconds
  if [ $((ELAPSED % 30)) -eq 0 ]; then
    echo "⏳ Still waiting for certificate readiness... (${ELAPSED}s/${TIMEOUT}s)"
    echo "   Current status: $STATUS - $MESSAGE"
  fi

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo ""
echo "=========================================="
echo "ERROR: Timeout waiting for TLS certificate"
echo "=========================================="
echo "Certificate: $CERT_NAME"
echo "Namespace: $NAMESPACE"
echo "Elapsed: ${TIMEOUT}s"
echo ""
echo "Certificate Status:"
kubectl get certificate "$CERT_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null || echo "  (unable to retrieve)"
echo ""
echo "Troubleshooting:"
echo "1. Check certificate status: kubectl get certificate $CERT_NAME -n $NAMESPACE"
echo "2. Check certificate events: kubectl describe certificate $CERT_NAME -n $NAMESPACE"
echo "3. Check cert-manager logs: kubectl logs -n cert-manager -l app=cert-manager"
echo "4. Check challenges: kubectl get challenges -n $NAMESPACE"
exit 1
