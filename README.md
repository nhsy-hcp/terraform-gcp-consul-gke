# Consul Service Mesh on GKE with API Gateway

A production-ready Terraform deployment of HashiCorp Consul service mesh on Google Kubernetes Engine (GKE) with the Consul API Gateway, automated TLS via cert-manager, and modular Helm charts.

## Architecture Overview

This deployment automatically provisions and creates:

**Infrastructure (via prereqs module):**

- **VPC Network**: Custom VPC with subnet (10.64.0.0/22)
- **Secondary IP Ranges**: Pods (10.64.64.0/18) and Services (10.64.4.0/22)
- **Cloud NAT**: For private GKE nodes to access internet
- **GCP APIs**: Automatically enables Container, Compute, DNS, IAM APIs

**Kubernetes Infrastructure:**

- **GKE Cluster**: Regional cluster with Workload Identity and Gateway API enabled
- **Consul Server Cluster**: 3-node HA cluster with persistent storage
- **Consul Connect**: Automatic Envoy sidecar injection for mTLS service mesh
- **Consul API Gateway**: Kubernetes Gateway API-compliant ingress with TLS termination
- **CNI Plugin**: Transparent proxy without NET_ADMIN init containers
- **cert-manager**: Automated Let's Encrypt certificates via DNS-01 challenge
- **Sample Services**: Backend and frontend with service mesh integration

## Prerequisites

### Required Tools

| Tool | Minimum Version | Installation |
|------|----------------|--------------|
| gcloud | Latest | [Install gcloud](https://cloud.google.com/sdk/docs/install) |
| kubectl | 1.25+ | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| helm | 3.6+ | [Install Helm](https://helm.sh/docs/intro/install/) |
| terraform | 1.5+ | [Install Terraform](https://developer.hashicorp.com/terraform/downloads) |
| task | 3.0+ | [Install Task](https://taskfile.dev/installation/) |

### GCP Requirements

- GCP project with billing enabled
- Container API enabled
- Cloud DNS managed zone configured
- IAM permissions to create GKE clusters and service accounts

## Quick Start

### 1. Clone and Configure

```bash
git clone <repository-url>
cd terraform-gcp-consul-gke

# Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
vim terraform/terraform.tfvars
```

**Required Configuration:**

```hcl
project_id    = "your-gcp-project-id"
dns_zone_name = "your-dns-zone-name"  # e.g., "example-com-zone"
domain        = "app.example.com"
cert_email    = "admin@example.com"
```

### 2. Deploy Infrastructure

```bash
# Initialize and apply Terraform
task init
task apply

# Get cluster credentials
task gke:credentials
```

This deploys:

- GKE cluster with Workload Identity
- Consul with service mesh (via Terraform module)
- cert-manager with DNS-01 solver (via Terraform module)
- Sample services and API Gateway (via Terraform module)

### 3. Verify Deployment

```bash
# Check all components
task status

# Get API Gateway IP
task gateway:get-ip

# Access Consul UI
task consul:get-token
task consul:port-forward
# Visit https://localhost:8501
```

### 4. Test the Gateway

```bash
# Test HTTP → HTTPS redirect and service routing
task consul:get-token
task consul:port-forward
task consul:logs
task cert-manager:logs
task gateway:get-ip
task gateway:test
```

## Project Structure

```
.
├── terraform/                          # Terraform infrastructure
│   ├── main.tf                        # Main configuration with modules
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output values
│   ├── terraform.tfvars.example       # Example configuration
│   ├── modules/                       # Terraform modules
│   │   ├── consul/                    # Consul Helm deployment
│   │   ├── cert-manager/              # cert-manager with Workload Identity
│   │   └── helm-charts/               # Services and gateway deployment
│   └── templates/
│       └── consul-values.yaml.tpl     # Consul Helm values template
├── helm/                              # Local Helm charts
│   ├── consul-services/               # Backend and frontend services
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── backend.yaml
│   │       ├── frontend.yaml
│   │       └── intentions.yaml
│   └── consul-gateway/                # API Gateway with TLS
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── gateway.yaml
│           ├── routes.yaml
│           └── tls.yaml
├── k8s/                               # Raw Kubernetes manifests (legacy)
├── Taskfile.yml                       # Task automation
├── README.md                          # This file
├── docs/                              # Documentation
│   ├── QUICKSTART.md                  # 15-minute deployment guide
│   └── ARCHITECTURE.md                # Detailed architecture docs

└── LICENSE                            # Apache 2.0 license
```

## Configuration

### Terraform Variables

Key variables in `terraform/terraform.tfvars`:

```hcl
# === Required ===
project_id    = "my-gcp-project"
dns_zone_name = "example-com-zone"
domain        = "app.example.com"
cert_email    = "admin@example.com"

# === Optional ===
region              = "us-central1"
cluster_name        = "consul-mesh-cluster"
node_count_per_zone = 1
machine_type        = "e2-standard-4"

# Consul configuration
consul_server_replicas = 3
consul_enable_connect  = true
consul_enable_cni      = true
consul_enable_gateway  = true

# TLS configuration
use_production_issuer = false  # Use staging for testing
```

### Helm Chart Customization

Customize services via `helm/consul-services/values.yaml`:

```yaml
backend:
  replicas: 2
  resources:
    requests:
      memory: "64Mi"
      cpu: "100m"

frontend:
  replicas: 2
  upstreams:
    - name: backend
      port: 9091
```

Customize gateway via `helm/consul-gateway/values.yaml`:

```yaml
gateway:
  https:
    hostname: app.example.com
    tlsMinVersion: "TLSv1_2"

tls:
  certificate:
    issuerName: letsencrypt-staging  # or letsencrypt-prod
```

## Common Tasks

### Using Task Runner

```bash
# Show all available tasks
task --list

# Infrastructure management
task init          # Initialize Terraform
task plan          # Show execution plan
task apply         # Apply infrastructure changes (staged, up to Helm charts)
task destroy       # Destroy all infrastructure (uninstalls K8s first)

# Deployment
task deploy:all       # Manually deploy/update services and gateway via Helm CLI
task deploy:services  # Manually deploy/update only services
task deploy:gateway   # Manually deploy/update only gateway

# Operations
task status           # Show status of all components
task gateway:ip       # Get API Gateway external IP
task test             # Run all tests
task test:gateway     # Test gateway endpoints

# Consul operations
task consul:get-token      # Get bootstrap ACL token
task consul:port-forward   # Access Consul UI locally

# Logs
task consul:logs           # View Consul server logs
task cert-manager:logs     # View cert-manager logs

# Cleanup
task uninstall    # Uninstall all Helm releases and namespaces
task clean        # Clean local Terraform cache and temp files
```

### Manual Helm Operations

```bash
# Deploy services with custom values
helm upgrade --install consul-services ./helm/consul-services \
  --namespace default \
  --set backend.replicas=3

# Deploy gateway with custom domain
helm upgrade --install consul-gateway ./helm/consul-gateway \
  --namespace consul \
  --set global.domain=myapp.example.com \
  --set tls.certificate.issuerName=letsencrypt-prod

# List releases
helm list -A

# Uninstall
helm uninstall consul-services -n default
helm uninstall consul-gateway -n consul
```

## Security

### Production Checklist

- [x] TLS enabled globally
- [x] ACLs enabled and managed
- [x] mTLS between services
- [x] Workload Identity for GCP IAM
- [x] Let's Encrypt certificates
- [ ] Default-deny service intentions
- [ ] Consul UI access restricted
- [ ] Network policies configured

### Switching to Production Certificates

After testing with staging:

```bash
# Update gateway Helm release
helm upgrade consul-gateway ./helm/consul-gateway \
  --namespace consul \
  --reuse-values \
  --set tls.certificate.issuerName=letsencrypt-prod

# Or update via Terraform
# Set use_production_issuer = true in terraform.tfvars
task apply
```

## Troubleshooting

### Certificate Issues

```bash
# Check certificate status
kubectl get certificate -n consul
kubectl describe certificate api-gateway-cert -n consul

# Check ACME challenges
kubectl get challenges -n consul
kubectl describe challenge <challenge-name> -n consul

# Verify DNS propagation
dig TXT _acme-challenge.app.example.com

# Check cert-manager logs
task cert-manager:logs
```

### Service Mesh Issues

```bash
# Check sidecar injection
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'

# Check service intentions
kubectl get serviceintentions

# View sidecar logs
kubectl logs <pod-name> -c consul-dataplane

# Check connect-inject logs
kubectl logs -n consul -l component=connect-injector
```

### Gateway Issues

```bash
# Check gateway status
kubectl get gateway api-gateway -n consul
kubectl describe gateway api-gateway -n consul

# Check routes
kubectl get httproute -A

# View gateway logs
kubectl logs -n consul -l component=api-gateway
```

## Documentation

- [Quick Start Guide](docs/QUICKSTART.md) - 15-minute deployment guide
- [Architecture Documentation](docs/ARCHITECTURE.md) - Detailed system design

## Additional Resources

- [Consul on Kubernetes](https://developer.hashicorp.com/consul/docs/k8s)
- [Consul API Gateway](https://developer.hashicorp.com/consul/docs/api-gateway)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test changes in a development environment first
4. Use conventional commit messages
5. Run `task lint` before submitting
