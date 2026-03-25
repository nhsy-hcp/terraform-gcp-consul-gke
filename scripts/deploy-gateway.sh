#!/bin/bash
set -euo pipefail

# Deploy API Gateway, routes, and TLS via Helm

# Fetch values from terraform output
PROJECT_ID=$(cd terraform && terraform output -raw project_id)
DOMAIN=$(cd terraform && terraform output -raw dns_zone_dns_name | sed 's/\.$//')
CERT_EMAIL=$(grep "cert_email" terraform/terraform.tfvars | cut -d'"' -f2)

CONSUL_NAMESPACE="${1:-consul}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-$PROJECT_ID}"
DOMAIN="${DOMAIN:-example.com}"
CERT_EMAIL="${CERT_EMAIL:-$CERT_EMAIL}"

echo "Deploying Gateway for domain: $DOMAIN in project: $GCP_PROJECT_ID"

helm upgrade --install consul-gateway ./helm/consul-gateway \
  --namespace "$CONSUL_NAMESPACE" \
  --set global.domain="$DOMAIN" \
  --set global.projectId="$GCP_PROJECT_ID" \
  --set gateway.https.hostname="$DOMAIN" \
  --set routes.frontend.hostname="$DOMAIN" \
  --set routes.backend.hostname="$DOMAIN" \
  --set tls.clusterIssuer.staging.email="$CERT_EMAIL" \
  --set tls.clusterIssuer.production.email="$CERT_EMAIL" \
  --set "tls.certificate.dnsNames[0]=$DOMAIN" \
  --set "tls.certificate.dnsNames[1]=*.$DOMAIN"

echo "✓ API Gateway, routes, and TLS deployed via Helm"
echo "Waiting for gateway to be ready..."
sleep 10
kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE"
