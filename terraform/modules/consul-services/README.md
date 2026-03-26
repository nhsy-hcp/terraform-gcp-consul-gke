# consul-services

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.consul_services](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_enabled"></a> [backend\_enabled](#input\_backend\_enabled) | Enable backend service | `bool` | `true` | no |
| <a name="input_backend_fqdn"></a> [backend\_fqdn](#input\_backend\_fqdn) | Fully Qualified Domain Name for the Backend service | `string` | n/a | yes |
| <a name="input_backend_replicas"></a> [backend\_replicas](#input\_backend\_replicas) | Number of backend replicas | `number` | `2` | no |
| <a name="input_consul_namespace"></a> [consul\_namespace](#input\_consul\_namespace) | Consul namespace dependency | `string` | n/a | yes |
| <a name="input_deploy_gateway"></a> [deploy\_gateway](#input\_deploy\_gateway) | Enable routes in the gateway | `bool` | `true` | no |
| <a name="input_deploy_services"></a> [deploy\_services](#input\_deploy\_services) | Deploy sample services (backend and frontend) | `bool` | `true` | no |
| <a name="input_frontend_enabled"></a> [frontend\_enabled](#input\_frontend\_enabled) | Enable frontend service | `bool` | `true` | no |
| <a name="input_frontend_fqdn"></a> [frontend\_fqdn](#input\_frontend\_fqdn) | Fully Qualified Domain Name for the Frontend service | `string` | n/a | yes |
| <a name="input_frontend_replicas"></a> [frontend\_replicas](#input\_frontend\_replicas) | Number of frontend replicas | `number` | `2` | no |
| <a name="input_gateway_namespace"></a> [gateway\_namespace](#input\_gateway\_namespace) | Kubernetes namespace for API Gateway | `string` | `"consul"` | no |
| <a name="input_gateway_release_name"></a> [gateway\_release\_name](#input\_gateway\_release\_name) | Gateway release name dependency | `string` | `""` | no |
| <a name="input_intentions_enabled"></a> [intentions\_enabled](#input\_intentions\_enabled) | Enable service intentions | `bool` | `true` | no |
| <a name="input_services_namespace"></a> [services\_namespace](#input\_services\_namespace) | Kubernetes namespace for sample services | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_services_namespace"></a> [services\_namespace](#output\_services\_namespace) | Kubernetes namespace for services |
| <a name="output_services_release_name"></a> [services\_release\_name](#output\_services\_release\_name) | Helm release name for consul-services |
<!-- END_TF_DOCS -->
