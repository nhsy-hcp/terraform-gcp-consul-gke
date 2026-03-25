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

FRONTEND_FQDN=$(cd terraform && terraform output -raw api_gateway_frontend_url | sed 's|^https://||' | sed 's|/$||')
BACKEND_FQDN=$(cd terraform && terraform output -raw api_gateway_backend_url | sed 's|^https://||' | sed 's|/$||')

echo "Testing Gateway at: $GATEWAY_IP"
echo "Frontend: $FRONTEND_FQDN"
echo "Backend:  $BACKEND_FQDN"
echo ""

echo "Testing HTTPS frontend:"
curl -k --resolve "$FRONTEND_FQDN:443:$GATEWAY_IP" "https://$FRONTEND_FQDN/"
echo ""

echo "Testing HTTPS backend:"
curl -k --resolve "$BACKEND_FQDN:443:$GATEWAY_IP" "https://$BACKEND_FQDN/"
echo ""

echo "✅ Gateway tests completed successfully!"
