#!/bin/bash
set -euo pipefail

# Retrieve Consul bootstrap ACL token

CONSUL_NAMESPACE="${1:-consul}"

TOKEN=$(kubectl get secret --namespace "$CONSUL_NAMESPACE" consul-bootstrap-acl-token --template='{{.data.token}}' | base64 -d)

echo "Consul Bootstrap Token:"
echo "$TOKEN"
echo ""
echo "Export it with:"
echo "export CONSUL_HTTP_TOKEN=\"$TOKEN\""
