# consul-gateway

This module deploys the Consul API Gateway with TLS certificate management via cert-manager and Let's Encrypt.

## LoadBalancer IP Wait Behavior

The module includes a `null_resource` that waits for the GCP LoadBalancer to be assigned an external IP address before completing. This ensures the `apigw_lb_address` output is always populated on successful deployment.

**Key Details:**
- **Timeout**: 120 seconds (2 minutes)
- **Script**: `scripts/wait-for-lb-ip.sh` must be executable
- **Trigger**: Re-runs when the gateway Helm release is recreated
- **Failure**: Terraform apply fails with clear error if IP not assigned within timeout

**Typical Provisioning Time:**
- GCP LoadBalancer IP assignment: 30-90 seconds
- The 120s timeout provides adequate buffer for slower provisioning

**Requirements:**
- `scripts/wait-for-lb-ip.sh` must exist and be executable
- `kubectl` must be configured with cluster access
- Bash shell must be available

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.consul_gateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.wait_for_gateway_ready](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_lb_ip](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [kubernetes_service_v1.api_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | List of CIDR blocks allowed to access external LoadBalancers | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_apigw_fqdn"></a> [apigw\_fqdn](#input\_apigw\_fqdn) | Fully Qualified Domain Name for the API Gateway | `string` | n/a | yes |
| <a name="input_cert_dns_names"></a> [cert\_dns\_names](#input\_cert\_dns\_names) | DNS names for the certificate | `list(string)` | `[]` | no |
| <a name="input_cert_email"></a> [cert\_email](#input\_cert\_email) | Email address for Let's Encrypt certificate notifications | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | cert-manager namespace dependency | `string` | n/a | yes |
| <a name="input_consul_namespace"></a> [consul\_namespace](#input\_consul\_namespace) | Consul namespace dependency | `string` | n/a | yes |
| <a name="input_deploy_gateway"></a> [deploy\_gateway](#input\_deploy\_gateway) | Deploy API Gateway with TLS | `bool` | `true` | no |
| <a name="input_gateway_namespace"></a> [gateway\_namespace](#input\_gateway\_namespace) | Kubernetes namespace for API Gateway | `string` | `"consul"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_use_production_issuer"></a> [use\_production\_issuer](#input\_use\_production\_issuer) | Use Let's Encrypt production issuer (set to false for staging) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigw_lb_address"></a> [apigw\_lb\_address](#output\_apigw\_lb\_address) | External IP of the API Gateway service |
| <a name="output_gateway_namespace"></a> [gateway\_namespace](#output\_gateway\_namespace) | Kubernetes namespace for gateway |
| <a name="output_gateway_release_name"></a> [gateway\_release\_name](#output\_gateway\_release\_name) | Helm release name for consul-gateway |
<!-- END_TF_DOCS -->
