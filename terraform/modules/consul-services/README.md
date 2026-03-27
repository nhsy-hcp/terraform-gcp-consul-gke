# consul-services

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.consul_services](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.wait_for_api_pods](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_web_pods](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_enabled"></a> [api\_enabled](#input\_api\_enabled) | Enable API service | `bool` | `true` | no |
| <a name="input_api_replicas"></a> [api\_replicas](#input\_api\_replicas) | Number of API replicas | `number` | `2` | no |
| <a name="input_consul_namespace"></a> [consul\_namespace](#input\_consul\_namespace) | Consul namespace dependency | `string` | n/a | yes |
| <a name="input_demo_fqdn"></a> [demo\_fqdn](#input\_demo\_fqdn) | Fully Qualified Domain Name for the demo application (shared by web and api) | `string` | n/a | yes |
| <a name="input_demo_namespace"></a> [demo\_namespace](#input\_demo\_namespace) | Kubernetes namespace for demo application services | `string` | `"demo"` | no |
| <a name="input_deploy_gateway"></a> [deploy\_gateway](#input\_deploy\_gateway) | Enable routes in the gateway | `bool` | `true` | no |
| <a name="input_deploy_services"></a> [deploy\_services](#input\_deploy\_services) | Deploy sample services (api and web) | `bool` | `true` | no |
| <a name="input_gateway_namespace"></a> [gateway\_namespace](#input\_gateway\_namespace) | Kubernetes namespace for API Gateway | `string` | `"consul"` | no |
| <a name="input_gateway_release_name"></a> [gateway\_release\_name](#input\_gateway\_release\_name) | Gateway release name dependency | `string` | `""` | no |
| <a name="input_intentions_enabled"></a> [intentions\_enabled](#input\_intentions\_enabled) | Enable service intentions | `bool` | `true` | no |
| <a name="input_pod_readiness_timeout"></a> [pod\_readiness\_timeout](#input\_pod\_readiness\_timeout) | Timeout in seconds for waiting for service pods to be ready | `number` | `120` | no |
| <a name="input_web_enabled"></a> [web\_enabled](#input\_web\_enabled) | Enable Web UI service | `bool` | `true` | no |
| <a name="input_web_replicas"></a> [web\_replicas](#input\_web\_replicas) | Number of Web UI replicas | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_demo_namespace"></a> [demo\_namespace](#output\_demo\_namespace) | Kubernetes namespace for demo application services |
| <a name="output_services_release_name"></a> [services\_release\_name](#output\_services\_release\_name) | Helm release name for consul-services |
<!-- END_TF_DOCS -->
