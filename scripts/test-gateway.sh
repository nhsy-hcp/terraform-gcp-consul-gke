#!/bin/bash
set -euo pipefail

# Test API Gateway endpoints with demo namespace support

CONSUL_NAMESPACE="${1:-consul}"
DEMO_NAMESPACE="${2:-demo}"

# Get the API Gateway service name
GATEWAY_SVC=$(kubectl get svc -n "$CONSUL_NAMESPACE" -l component=api-gateway -o name | head -n 1 || true)

if [ -z "$GATEWAY_SVC" ]; then
  echo "Error: API Gateway service not found in namespace $CONSUL_NAMESPACE."
  echo "Make sure it's deployed using 'task apply:helm-charts'."
  exit 1
fi

# Get the external IP
GATEWAY_IP=$(kubectl get "$GATEWAY_SVC" -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)

if [ -z "$GATEWAY_IP" ]; then
  echo "Gateway IP not yet assigned for $GATEWAY_SVC. This may take a few minutes."
  echo "You can check the status with: kubectl get $GATEWAY_SVC -n $CONSUL_NAMESPACE"
  exit 1
fi

DEMO_FQDN=$(cd terraform && terraform output -raw demo_fqdn | sed 's|/$||')

echo "Testing Gateway at: $GATEWAY_IP"
echo "Demo FQDN: $DEMO_FQDN"
echo "Demo Namespace: $DEMO_NAMESPACE"
echo ""

echo "Testing HTTPS Web UI (root path):"
echo "Command: curl -k -s -v --resolve \"$DEMO_FQDN:443:$GATEWAY_IP\" \"https://$DEMO_FQDN/\""
WEB_RESPONSE=$(curl -k -s -v --resolve "$DEMO_FQDN:443:$GATEWAY_IP" "https://$DEMO_FQDN/" 2>&1)
echo "$WEB_RESPONSE"
echo ""

# Extract and validate web HTTP status code
WEB_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --resolve "$DEMO_FQDN:443:$GATEWAY_IP" "https://$DEMO_FQDN/")
if [[ "$WEB_STATUS" -ge 200 && "$WEB_STATUS" -lt 300 ]]; then
  echo "✅ Web UI test passed (HTTP $WEB_STATUS)"
else
  echo "❌ Web UI test failed (HTTP $WEB_STATUS)"
  exit 1
fi
echo ""

echo "Testing HTTPS API (/api path):"
echo "Command: curl -k -s -v --resolve \"$DEMO_FQDN:443:$GATEWAY_IP\" \"https://$DEMO_FQDN/api\""
API_RESPONSE=$(curl -k -s -v --resolve "$DEMO_FQDN:443:$GATEWAY_IP" "https://$DEMO_FQDN/api" 2>&1)
echo "$API_RESPONSE"
echo ""

# Extract and validate API HTTP status code
API_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --resolve "$DEMO_FQDN:443:$GATEWAY_IP" "https://$DEMO_FQDN/api")
if [[ "$API_STATUS" -ge 200 && "$API_STATUS" -lt 300 ]]; then
  echo "✅ API test passed (HTTP $API_STATUS)"
else
  echo "❌ API test failed (HTTP $API_STATUS)"
  exit 1
fi
echo ""

echo "✅ All gateway tests completed successfully!"
