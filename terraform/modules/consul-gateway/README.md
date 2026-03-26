# consul-gateway

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.consul_gateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_service_v1.api_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | List of CIDR blocks allowed to access external LoadBalancers | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_apigw_fqdn"></a> [apigw\_fqdn](#input\_apigw\_fqdn) | Fully Qualified Domain Name for the API Gateway | `string` | n/a | yes |
| <a name="input_cert_dns_names"></a> [cert\_dns\_names](#input\_cert\_dns\_names) | DNS names for the certificate | `list(string)` | `[]` | no |
| <a name="input_cert_email"></a> [cert\_email](#input\_cert\_email) | Email address for Let's Encrypt certificate notifications | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | cert-manager namespace dependency | `string` | n/a | yes |
| <a name="input_consul_fqdn"></a> [consul\_fqdn](#input\_consul\_fqdn) | Fully Qualified Domain Name for Consul | `string` | n/a | yes |
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
