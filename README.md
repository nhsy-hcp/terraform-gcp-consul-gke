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
# Initialize and apply Terraform (includes automatic credential configuration)
task init
task apply
```

**Deployment Process:**

The `task apply` command performs a **staged deployment** with automatic validation:

1. **Prerequisites**: VPC, APIs, networking
2. **GKE Cluster**: Regional cluster with Workload Identity
3. **Consul Service Mesh**: 3-node HA cluster with Connect
4. **cert-manager**: Automated TLS certificate management
5. **Application Helm Charts** (staged):
   - **Gateway API CRDs**: Auto-installed if missing (HTTPRoute, Gateway, etc.)
   - **Services**: Backend and frontend deployed first
   - **API Gateway**: Deployed after services are ready
   - **LoadBalancer IP Wait**: Terraform automatically waits up to 120s for GCP to assign external IP
   - **Verification**: TLS certificate validation

Each stage includes confirmation prompts. Use `task apply -- --yes` to skip prompts for CI/CD.

**Note:** The API Gateway deployment includes an automatic wait for LoadBalancer IP assignment (up to 120 seconds). This ensures the `apigw_lb_address` output is always populated on successful deployment, eliminating race conditions.

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
.
├── terraform/                          # Terraform infrastructure
│   ├── main.tf                        # Main configuration with modules
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output values
│   ├── terraform.tfvars.example       # Example configuration
│   ├── modules/                       # Terraform modules
│   │   ├── prereqs/                   # VPC, APIs, and prerequisites
│   │   ├── gke/                       # GKE cluster
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
│   │       ├── intentions.yaml
│   │       └── servicedefaults.yaml
│   └── consul-gateway/                # API Gateway with TLS
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── gateway.yaml
│           ├── routes.yaml
│           └── tls.yaml
├── scripts/                           # Utility scripts
│   ├── deploy-gateway.sh
│   ├── get-consul-token.sh
│   ├── show-status.sh
│   ├── test-gateway.sh
│   ├── verify-workload-identity.sh
│   └── wait-for-lb-ip.sh
├── Taskfile.yml                       # Task automation
├── AGENTS.md                          # AI agent guidelines
├── README.md                          # This file
├── docs/                              # Documentation
│   └── ARCHITECTURE.md                # Detailed architecture docs
└── LICENSE                            # Apache 2.0 license
```

## Configuration

### Terraform Variables

Edit `terraform/terraform.tfvars` (copy from `terraform.tfvars.example`):

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

All infrastructure and services are deployed via Terraform modules. Customize by modifying variables in `terraform.tfvars` and re-running `task apply`.

## Common Tasks

### Using Task Runner

```bash
# Show all available tasks
task --list

# Infrastructure management
task init          # Initialize Terraform
task plan          # Show execution plan
task apply         # Apply infrastructure changes (staged deployment)
task destroy       # Destroy all infrastructure

# Operations
task status               # Show status of all components
task gateway:ip           # Get API Gateway external IP
task gateway:test         # Test gateway endpoints
task verify:gateway-tls   # Verify API Gateway TLS certificate status
task recreate:certificate # Force recreation of API Gateway TLS certificate

# Consul operations
task consul:token         # Get bootstrap ACL token
task consul:port-forward  # Access Consul UI locally
task consul:logs          # View Consul server logs

# UI operations (open in browser)
task ui                # Open frontend, backend, and Consul UI
task ui:consul         # Open Consul UI only
task ui:gateway        # Open API Gateway URL

# Logs
task cert-manager:logs # View cert-manager logs

# Cleanup
task uninstall         # Uninstall all Helm releases and namespaces
task clean             # Clean local Terraform cache and temp files
```

## Security

### Switching to Production Certificates

After testing with staging certificates, update `terraform/terraform.tfvars`:

```hcl
use_production_issuer = true
```

Then apply the change:

```bash
task apply
```

## Troubleshooting

### Certificate Issues

```bash
# Run comprehensive TLS verification (recommended first step)
task verify:gateway-tls

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

# Verify Workload Identity configuration
task workload-identity:verify
```

**Common Certificate Issues:**

1. **DNS-01 Challenge Failures (SERVFAIL)**
   - Verify Cloud DNS zone exists and is accessible
   - Check cert-manager service account has `roles/dns.admin` permission
   - Verify Workload Identity binding: `task workload-identity:verify`

2. **Certificate Not Ready**
   - Run `task verify:gateway-tls` for detailed diagnostics
   - Check ClusterIssuer status: `kubectl get clusterissuer`
   - Review cert-manager logs: `task cert-manager:logs`

3. **Gateway Listener Not Programmed**
   - Verify TLS secret exists: `kubectl get secret api-gateway-tls -n consul`
   - Check Gateway status: `kubectl describe gateway api-gateway -n consul`
   - Certificate must be ready before Gateway listener can be programmed

4. **InvalidCertificateRef Warning (Non-Blocking)**
   - **Symptom**: Gateway shows `InvalidCertificateRef` with message "certificate is invalid or does not contain a supported server name"
   - **Cause**: Gateway listener missing hostname field (known limitation)
   - **Impact**: Warning only - Gateway functions normally, TLS termination works correctly
   - **Verification**: Certificate SANs include wildcard domain, Gateway accepts all traffic
   - **Status**: This is a known cosmetic issue and does not affect functionality

**Force Certificate Recreation:**

If the certificate is stuck or has persistent issues, you can force a recreation:

```bash
# Delete and recreate the certificate (with confirmation prompt)
task recreate:certificate

# Monitor the new certificate issuance
task verify:gateway-tls

# Watch cert-manager logs in real-time
task cert-manager:logs
```

This will:
1. Delete the existing Certificate, CertificateRequest, Challenges, and TLS secret
2. Trigger Terraform to recreate the certificate via the helm-charts module
3. Start a fresh ACME challenge process

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

# Verify Gateway API CRDs are installed
kubectl get crd | grep gateway.networking.k8s.io
```

**Gateway API CRDs:**

The deployment automatically installs required Gateway API CRDs (Gateway, HTTPRoute, ReferenceGrant) if they are missing. This is handled by the `validate:gateway-crds` task which runs before helm chart deployment.

If you encounter CRD-related errors:
```bash
# Manually verify and install CRDs
task validate:gateway-crds

# Check installed CRDs
kubectl get crd | grep gateway
```

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
