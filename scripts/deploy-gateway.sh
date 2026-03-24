#!/bin/bash
set -euo pipefail

# Deploy API Gateway, routes, and TLS via Helm

CONSUL_NAMESPACE="${1:-consul}"
DOMAIN="${DOMAIN:-example.com}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-my-gcp-project}"
CERT_EMAIL="${CERT_EMAIL:-admin@example.com}"

helm upgrade --install consul-gateway ./helm/consul-gateway \
  --namespace "$CONSUL_NAMESPACE" \
  --set global.domain="$DOMAIN" \
  --set global.projectId="$GCP_PROJECT_ID" \
  --set gateway.https.hostname="$DOMAIN" \
  --set routes.frontend.hostname="$DOMAIN" \
  --set routes.backend.hostname="$DOMAIN" \
  --set tls.clusterIssuer.staging.email="$CERT_EMAIL" \
  --set tls.clusterIssuer.production.email="$CERT_EMAIL"

echo "✓ API Gateway, routes, and TLS deployed via Helm"
echo "Waiting for gateway to be ready..."
sleep 10
kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE"
