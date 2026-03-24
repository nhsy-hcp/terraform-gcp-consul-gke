#!/bin/bash
set -euo pipefail

# Show status of all Consul on GKE components

CONSUL_NAMESPACE="${1:-consul}"

echo "=== GKE Cluster ==="
kubectl get nodes
echo ""

echo "=== Consul Pods ==="
kubectl get pods -n "$CONSUL_NAMESPACE"
echo ""

echo "=== Sample Services ==="
kubectl get pods -l app=backend
kubectl get pods -l app=frontend
echo ""

echo "=== API Gateway ==="
kubectl get gateway -n "$CONSUL_NAMESPACE"
kubectl get svc -n "$CONSUL_NAMESPACE" -l component=api-gateway
echo ""

echo "=== Certificates ==="
kubectl get certificate -n "$CONSUL_NAMESPACE"
echo ""

echo "=== Service Intentions ==="
kubectl get serviceintentions
