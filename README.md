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
| terraform | 1.5+ | [Install Terraform](https://developer.hashicorp.com/terraform/downloads) |
| task | 3.0+ | [Install Task](https://taskfile.dev/installation/) |

**Note:** Helm is used internally by Terraform and does not need to be installed separately.

### GCP Requirements

- GCP project with billing enabled
- Container API enabled
- Cloud DNS managed zone configured (domain is automatically derived from this zone)
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
cert_email    = "admin@example.com"
```

### 2. Deploy Infrastructure

```bash
# Initialize and apply Terraform (includes automatic credential configuration)
task init
task apply
```

The deployment runs in 5 stages with automatic validation:
1. Prerequisites (VPC, APIs)
2. GKE Cluster
3. Consul Service Mesh
4. cert-manager
5. Application Helm Charts (Gateway + Services)

Use `task apply -- --yes` to skip confirmation prompts.

### 3. Verify Deployment

```bash
# Check all components
task status

# Get API Gateway IP
task gateway:ip

# Access Consul UI
task consul:token
task consul:port-forward
# Visit https://localhost:8501
```

### 4. Test the Gateway

```bash
# Test HTTP → HTTPS redirect and service routing
task gateway:test
```

## Project Structure

```
terraform/          # Infrastructure as code
  modules/          # Reusable Terraform modules
  templates/        # Configuration templates
helm/               # Local Helm charts
  consul-services/  # Sample services
  consul-gateway/   # API Gateway with TLS
scripts/            # Utility scripts
Taskfile.yml        # Task automation
```

## Configuration

### Terraform Variables

Edit `terraform/terraform.tfvars` (copy from `terraform.tfvars.example`):

```hcl
# === Required ===
project_id    = "my-gcp-project"
dns_zone_name = "example-com-zone"
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

All infrastructure and services are deployed via Terraform modules. Customize by modifying variables in `terraform.tfvars` and re-running `task apply`.

## Common Tasks

```bash
task --list            # Show all tasks
task init              # Initialize Terraform
task apply             # Deploy infrastructure (staged)
task status            # Check component status
task gateway:test      # Test gateway endpoints
task consul:token      # Get Consul ACL token
task ui                # Open UIs in browser
task destroy           # Destroy infrastructure
```

## Production Certificates

Switch from staging to production Let's Encrypt:

```hcl
# terraform/terraform.tfvars
use_production_issuer = true
```

Then: `task apply`

## Troubleshooting

### Quick Diagnostics

```bash
# Verify all components
task verify:gateway-tls    # TLS certificate status
task status                # All component status
task cert-manager:logs     # cert-manager logs
```

### Common Issues

**Certificate Problems:**
- DNS-01 failures: Verify Cloud DNS zone and cert-manager service account permissions
- Certificate stuck: Use `task recreate:certificate` to force recreation
- Workload Identity: Run `task workload-identity:verify`

**Gateway Issues:**
- Gateway not programmed: Check `kubectl describe gateway api-gateway -n consul`
- Missing CRDs: Run `task validate:gateway-crds`
- View logs: `kubectl logs -n consul -l component=api-gateway`

**Service Mesh:**
- Check sidecar injection: `kubectl get pods -o wide`
- View intentions: `kubectl get serviceintentions`
- Sidecar logs: `kubectl logs <pod> -c consul-dataplane`

## Documentation

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
