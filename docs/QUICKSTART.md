# Consul on GKE - 15 Minute Quickstart

Get a production-ready Consul service mesh with API Gateway running on GKE in 15 minutes.

## Prerequisites

- GCP project with billing enabled
- `gcloud`, `kubectl`, `terraform`, `helm`, and `task` installed
- A registered domain with Cloud DNS zone configured

## Step-by-Step Deployment

### 1. Configure (2 minutes)

```bash
# Clone repository
git clone <repository-url>
cd terraform-gcp-consul-gke

# Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your values:

```hcl
project_id    = "your-gcp-project-id"
dns_zone_name = "your-dns-zone-name"  # e.g., "example-com-zone"
domain        = "app.example.com"
cert_email    = "admin@example.com"
```

### 2. Deploy Infrastructure (8 minutes)

```bash
# Initialize and deploy everything
task init
task deploy
```

This single command deploys:

- ✅ GKE cluster with Workload Identity
- ✅ Consul service mesh (3 servers, HA)
- ✅ cert-manager with DNS-01 solver
- ✅ Sample services (backend + frontend)
- ✅ API Gateway with TLS

### 3. Get Credentials (1 minute)

```bash
# Configure kubectl
task gke:credentials

# Verify deployment
task status
```

### 4. Access Services (2 minutes)

```bash
# Get API Gateway IP
task get:gateway-ip

# Get Consul bootstrap token
task get:consul-token

# Access Consul UI (in another terminal)
task port-forward-consul
# Visit https://localhost:8501
```

### 5. Test the Gateway (2 minutes)

```bash
# Test HTTP → HTTPS redirect and routing
task consul:token
task consul:logs
task cert-manager:logs
task consul:port-forward
task gateway:ip
task gateway:test
task consul:backup
task consul:upgrade
task cert-manager:verify-workload-identity

# Or manually test
GATEWAY_IP=$(kubectl get svc -n consul -l component=api-gateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

# Test HTTP (should redirect to HTTPS)
curl -I http://$GATEWAY_IP/

# Test HTTPS endpoints
curl -k https://$GATEWAY_IP/        # Frontend
curl -k https://$GATEWAY_IP/api     # Backend
```

## What You Get

### Infrastructure

- **GKE Cluster**: Regional, 3 zones, Workload Identity enabled
- **Consul**: 3-server HA cluster with persistent storage
- **Service Mesh**: Automatic Envoy sidecar injection, mTLS
- **API Gateway**: Kubernetes Gateway API with TLS termination
- **TLS**: Automated Let's Encrypt certificates via DNS-01

### Sample Application

- **Backend Service**: 2 replicas with Consul Connect
- **Frontend Service**: 2 replicas with upstream to backend
- **Service Intentions**: Authorization rules (frontend → backend)
- **HTTP Routes**: Frontend at `/`, Backend at `/api`

### Security

- ✅ TLS everywhere (Consul internal + Gateway external)
- ✅ ACLs enabled
- ✅ mTLS between services
- ✅ Workload Identity for GCP IAM
- ✅ Let's Encrypt certificates (staging by default)

## Next Steps

### Switch to Production Certificates

After testing with staging certificates:

```bash
# Update to production issuer
helm upgrade consul-gateway ./helm/consul-gateway \
  --namespace consul \
  --reuse-values \
  --set tls.certificate.issuerName=letsencrypt-prod

# Monitor certificate issuance
kubectl get certificate -n consul -w
```

Or via Terraform:

```hcl
# In terraform/terraform.tfvars
use_production_issuer = true
```

```bash
task deploy
```

### Configure DNS

Point your domain to the Gateway IP:

```bash
# Get the IP
GATEWAY_IP=$(kubectl get svc -n consul -l component=api-gateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

# Create A record in Cloud DNS
gcloud dns record-sets create app.example.com. \
  --zone=your-dns-zone-name \
  --type=A \
  --ttl=300 \
  --rrdatas=$GATEWAY_IP
```

### Deploy Your Own Services

1. **Create service manifests** with Consul annotations:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
spec:
  template:
    metadata:
      annotations:
        consul.hashicorp.com/connect-inject: "true"
    spec:
      containers:
        - name: my-service
          image: my-image:latest
```

2. **Add service intentions** for authorization:

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: my-service
spec:
  destination:
    name: my-service
  sources:
    - name: frontend
      action: allow
```

3. **Add HTTPRoute** to expose via Gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: my-service-route
spec:
  parentRefs:
    - name: api-gateway
      namespace: consul
      sectionName: https
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /my-service
      backendRefs:
        - name: my-service
          port: 80
```

### Customize Configuration

Edit Helm chart values:

```bash
# Customize services
vim helm/consul-services/values.yaml

# Customize gateway
vim helm/consul-gateway/values.yaml

# Redeploy
helm upgrade consul-services ./helm/consul-services -n default
helm upgrade consul-gateway ./helm/consul-gateway -n consul
```

Or via Terraform variables:

```hcl
# In terraform/terraform.tfvars
backend_replicas  = 3
frontend_replicas = 3
consul_server_replicas = 5
```

```bash
task deploy
```

## Troubleshooting

### Certificate Not Issuing

```bash
# Check certificate status
kubectl describe certificate api-gateway-cert -n consul

# Check challenges
kubectl get challenges -n consul

# Verify DNS propagation
dig TXT _acme-challenge.app.example.com

# Check cert-manager logs
task logs:cert-manager
```

### Services Can't Communicate

```bash
# Check service intentions
kubectl get serviceintentions

# Check sidecar injection
kubectl get pods -o wide

# View sidecar logs
kubectl logs <pod-name> -c consul-dataplane
```

### Gateway Not Accessible

```bash
# Check gateway status
kubectl get gateway api-gateway -n consul
kubectl describe gateway api-gateway -n consul

# Check service
kubectl get svc -n consul -l component=api-gateway

# View gateway logs
kubectl logs -n consul -l component=api-gateway
```

## Cleanup

```bash
# Remove all resources
task clean:k8s
task destroy

# Or destroy everything at once
task destroy-auto
```

## Common Commands

```bash
# Show all available tasks
task --list

# View component status
task status

# Access Consul UI
task port-forward-consul

# View logs
task consul:token
task consul:logs
task cert-manager:logs
task consul:port-forward
task gateway:ip
task gateway:test
task consul:backup
task consul:upgrade
task cert-manager:verify-workload-identity
task logs:cert-manager

# Test gateway
task consul:token
task consul:logs
task cert-manager:logs
task consul:port-forward
task gateway:ip
task gateway:test
task consul:backup
task consul:upgrade
task cert-manager:verify-workload-identity
```

## What's Next?

- Read [README.md](README.md) for detailed documentation
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Check [Consul documentation](https://developer.hashicorp.com/consul/docs/k8s)
- Explore [Gateway API docs](https://gateway-api.sigs.k8s.io/)

---

**Time to Production**: ~15 minutes ⚡
