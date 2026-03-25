#!/bin/bash
set -euo pipefail

# Test API Gateway endpoints

CONSUL_NAMESPACE="${1:-consul}"

# Get the API Gateway service name
GATEWAY_SVC=$(kubectl get svc -n "$CONSUL_NAMESPACE" -l component=api-gateway -o name | head -n 1 || true)

if [ -z "$GATEWAY_SVC" ]; then
  echo "Error: API Gateway service not found in namespace $CONSUL_NAMESPACE."
  echo "Make sure it's deployed using 'task deploy:gateway' or 'task apply:helm-charts'."
  exit 1
fi

# Get the external IP
GATEWAY_IP=$(kubectl get "$GATEWAY_SVC" -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)

if [ -z "$GATEWAY_IP" ]; then
  echo "Gateway IP not yet assigned for $GATEWAY_SVC. This may take a few minutes."
  echo "You can check the status with: kubectl get $GATEWAY_SVC -n $CONSUL_NAMESPACE"
  exit 1
fi

DOMAIN=$(cd terraform && terraform output -raw dns_zone_dns_name | sed 's/\.$//')

echo "Testing Gateway at: $GATEWAY_IP (Domain: $DOMAIN)"
echo ""

echo "Testing HTTP (should redirect to HTTPS):"
curl -I -H "Host: $DOMAIN" "http://$GATEWAY_IP/"
echo ""

echo "Testing HTTPS frontend:"
curl -k -H "Host: $DOMAIN" "https://$GATEWAY_IP/"
echo ""

echo "Testing HTTPS backend:"
curl -k -H "Host: $DOMAIN" "https://$GATEWAY_IP/api"
