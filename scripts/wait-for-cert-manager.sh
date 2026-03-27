#!/bin/bash
set -euo pipefail

# Wait for cert-manager deployments to be ready
# Usage: wait-for-cert-manager.sh [namespace]

NAMESPACE="${1:-cert-manager}"
TIMEOUT=120

echo "=========================================="
echo "Waiting for cert-manager Deployments"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo "Timeout: ${TIMEOUT}s per deployment"
echo ""

# Wait for deployments to exist first
for deployment in cert-manager cert-manager-webhook cert-manager-cainjector; do
  echo "Checking if deployment $deployment exists..."
  ELAPSED=0
  while [ $ELAPSED -lt 60 ]; do
    if kubectl get deployment "$deployment" -n "$NAMESPACE" >/dev/null 2>&1; then
      echo "✓ Deployment $deployment exists"
      break
    fi
    if [ $((ELAPSED % 10)) -eq 0 ]; then
      echo "⏳ Waiting for deployment $deployment to be created... (${ELAPSED}s/60s)"
    fi
    sleep 10
    ELAPSED=$((ELAPSED + 10))
  done

  if [ $ELAPSED -ge 60 ]; then
    echo ""
    echo "=========================================="
    echo "ERROR: Deployment $deployment not created"
    echo "=========================================="
    echo "Namespace: $NAMESPACE"
    echo "Elapsed: 60s"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check Helm release: helm list -n $NAMESPACE"
    echo "2. Check pods: kubectl get pods -n $NAMESPACE"
    echo "3. Check Helm release status: helm status cert-manager -n $NAMESPACE"
    exit 1
  fi
done

echo ""
echo "All deployments exist. Waiting for them to be available..."
echo ""

# Now wait for them to be available
kubectl wait --for=condition=available deployment/cert-manager -n "$NAMESPACE" --timeout=${TIMEOUT}s
kubectl wait --for=condition=available deployment/cert-manager-webhook -n "$NAMESPACE" --timeout=${TIMEOUT}s
kubectl wait --for=condition=available deployment/cert-manager-cainjector -n "$NAMESPACE" --timeout=${TIMEOUT}s

echo ""
echo "Verifying cert-manager CRDs..."
for crd in certificates.cert-manager.io \
           clusterissuers.cert-manager.io \
           issuers.cert-manager.io \
           certificaterequests.cert-manager.io \
           orders.acme.cert-manager.io \
           challenges.acme.cert-manager.io; do
  echo "Checking CRD $crd..."
  ELAPSED=0
  while [ $ELAPSED -lt 60 ]; do
    if kubectl get crd "$crd" &>/dev/null; then
      echo "✓ CRD $crd is present"
      break
    fi
    if [ $((ELAPSED % 10)) -eq 0 ]; then
      echo "⏳ Waiting for CRD $crd to be registered... (${ELAPSED}s/60s)"
    fi
    sleep 10
    ELAPSED=$((ELAPSED + 10))
  done

  if [ $ELAPSED -ge 60 ]; then
    echo ""
    echo "=========================================="
    echo "ERROR: CRD $crd not registered"
    echo "=========================================="
    echo "Namespace: $NAMESPACE"
    echo "Elapsed: 60s"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check cert-manager pods: kubectl get pods -n $NAMESPACE"
    echo "2. Check cert-manager logs: kubectl logs -n $NAMESPACE -l app=cert-manager"
    echo "3. Check CRD installation: kubectl get crds | grep cert-manager"
    exit 1
  fi
done

echo ""
echo "Waiting for cert-manager to initialize ACME client..."
sleep 30

echo ""
echo "✓ cert-manager is ready"
echo "✓ All deployments are available"
echo "✓ All CRDs are registered"
echo ""
echo "cert-manager is ready for certificate issuance"
