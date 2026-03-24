#!/bin/bash
set -euo pipefail

# Create a snapshot of Consul data

CONSUL_NAMESPACE="${1:-consul}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="backup-$TIMESTAMP.snap"

echo "Creating Consul snapshot..."
kubectl exec -n "$CONSUL_NAMESPACE" consul-server-0 -- consul snapshot save "/tmp/$BACKUP_FILE"

echo "Copying snapshot to local machine..."
kubectl cp "$CONSUL_NAMESPACE/consul-server-0:/tmp/$BACKUP_FILE" "./$BACKUP_FILE"

echo "✓ Backup saved to $BACKUP_FILE"
