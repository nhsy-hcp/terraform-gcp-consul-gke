#!/bin/bash
set -euo pipefail

# Verify Workload Identity is configured correctly for cert-manager

CERT_MANAGER_NAMESPACE="${1:-cert-manager}"

echo "Testing Workload Identity for cert-manager..."
kubectl run wi-test --image=google/cloud-sdk:slim \
  --namespace "$CERT_MANAGER_NAMESPACE" \
  --serviceaccount=cert-manager \
  --rm --restart=Never \
  -- gcloud auth list
