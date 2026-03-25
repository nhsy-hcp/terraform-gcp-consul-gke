# helm-charts

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.consul_gateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.consul_services](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_service_v1.api_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | List of CIDR blocks allowed to access external LoadBalancers | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_apigw_fqdn"></a> [apigw\_fqdn](#input\_apigw\_fqdn) | Fully Qualified Domain Name for the API Gateway | `string` | n/a | yes |
| <a name="input_backend_enabled"></a> [backend\_enabled](#input\_backend\_enabled) | Enable backend service | `bool` | `true` | no |
| <a name="input_backend_replicas"></a> [backend\_replicas](#input\_backend\_replicas) | Number of backend replicas | `number` | `2` | no |
| <a name="input_cert_dns_names"></a> [cert\_dns\_names](#input\_cert\_dns\_names) | DNS names for the certificate | `list(string)` | `[]` | no |
| <a name="input_cert_email"></a> [cert\_email](#input\_cert\_email) | Email address for Let's Encrypt certificate notifications | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | cert-manager namespace dependency | `string` | n/a | yes |
| <a name="input_consul_namespace"></a> [consul\_namespace](#input\_consul\_namespace) | Consul namespace dependency | `string` | n/a | yes |
| <a name="input_deploy_gateway"></a> [deploy\_gateway](#input\_deploy\_gateway) | Deploy API Gateway with TLS | `bool` | `true` | no |
| <a name="input_deploy_services"></a> [deploy\_services](#input\_deploy\_services) | Deploy sample services (backend and frontend) | `bool` | `true` | no |
| <a name="input_frontend_enabled"></a> [frontend\_enabled](#input\_frontend\_enabled) | Enable frontend service | `bool` | `true` | no |
| <a name="input_frontend_replicas"></a> [frontend\_replicas](#input\_frontend\_replicas) | Number of frontend replicas | `number` | `2` | no |
| <a name="input_gateway_namespace"></a> [gateway\_namespace](#input\_gateway\_namespace) | Kubernetes namespace for API Gateway | `string` | `"consul"` | no |
| <a name="input_intentions_enabled"></a> [intentions\_enabled](#input\_intentions\_enabled) | Enable service intentions | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_services_namespace"></a> [services\_namespace](#input\_services\_namespace) | Kubernetes namespace for sample services | `string` | `"default"` | no |
| <a name="input_use_production_issuer"></a> [use\_production\_issuer](#input\_use\_production\_issuer) | Use Let's Encrypt production issuer (set to false for staging) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_ip"></a> [api\_gateway\_ip](#output\_api\_gateway\_ip) | External IP of the API Gateway service |
| <a name="output_gateway_namespace"></a> [gateway\_namespace](#output\_gateway\_namespace) | Kubernetes namespace for gateway |
| <a name="output_gateway_release_name"></a> [gateway\_release\_name](#output\_gateway\_release\_name) | Helm release name for consul-gateway |
| <a name="output_services_namespace"></a> [services\_namespace](#output\_services\_namespace) | Kubernetes namespace for services |
| <a name="output_services_release_name"></a> [services\_release\_name](#output\_services\_release\_name) | Helm release name for consul-services |
<!-- END_TF_DOCS -->
