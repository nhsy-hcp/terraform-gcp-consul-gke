#!/bin/bash
set -euo pipefail

# Validate and install Gateway API CRDs if missing

echo "Checking for required Gateway API CRDs..."
MISSING_CRDS=""

for CRD in gateways.gateway.networking.k8s.io \
           gatewayclasses.gateway.networking.k8s.io \
           httproutes.gateway.networking.k8s.io \
           referencegrants.gateway.networking.k8s.io; do
  if ! kubectl get crd "$CRD" &>/dev/null; then
    MISSING_CRDS="$MISSING_CRDS $CRD"
  fi
done

if [ -n "$MISSING_CRDS" ]; then
  echo "⚠ Missing required CRDs:$MISSING_CRDS"
  echo "Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
  echo "✓ Gateway API CRDs installed"
else
  echo "✓ All required Gateway API CRDs present"
fi
