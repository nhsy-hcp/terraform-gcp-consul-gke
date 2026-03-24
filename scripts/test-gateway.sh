#!/bin/bash
set -euo pipefail

# Test API Gateway endpoints

CONSUL_NAMESPACE="${1:-consul}"

GATEWAY_IP=$(kubectl get svc -n "$CONSUL_NAMESPACE" -l component=api-gateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

if [ -z "$GATEWAY_IP" ]; then
  echo "Gateway IP not yet assigned. Please wait and try again."
  exit 1
fi

echo "Testing Gateway at: $GATEWAY_IP"
echo ""

echo "Testing HTTP (should redirect to HTTPS):"
curl -I "http://$GATEWAY_IP/"
echo ""

echo "Testing HTTPS frontend:"
curl -k "https://$GATEWAY_IP/"
echo ""

echo "Testing HTTPS backend:"
curl -k "https://$GATEWAY_IP/api"
