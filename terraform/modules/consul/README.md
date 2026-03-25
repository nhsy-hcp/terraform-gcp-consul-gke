# consul

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.24.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_service_account.consul_server](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.consul_server_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [helm_release.consul](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.consul](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_service_v1.consul_ui](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acls_enabled"></a> [acls\_enabled](#input\_acls\_enabled) | Enable ACLs for Consul | `bool` | `true` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | List of CIDR blocks allowed to access external LoadBalancers | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Consul Helm chart version | `string` | `"1.9.5"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster | `string` | n/a | yes |
| <a name="input_datacenter"></a> [datacenter](#input\_datacenter) | Consul datacenter name | `string` | `"dc1"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for Consul | `string` | `"consul"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name for Consul | `string` | `"consul"` | no |
| <a name="input_server_replicas"></a> [server\_replicas](#input\_server\_replicas) | Number of Consul server replicas | `number` | `3` | no |
| <a name="input_skip_crds"></a> [skip\_crds](#input\_skip\_crds) | Skip installation of CRDs by Helm | `bool` | `true` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Storage class for Consul persistent volumes | `string` | `"standard-rwo"` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Storage size for Consul persistent volumes | `string` | `"10Gi"` | no |
| <a name="input_tls_enabled"></a> [tls\_enabled](#input\_tls\_enabled) | Enable TLS for Consul | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Consul Helm chart version |
| <a name="output_consul_lb_address"></a> [consul\_lb\_address](#output\_consul\_lb\_address) | External IP of the Consul UI service |
| <a name="output_datacenter"></a> [datacenter](#output\_datacenter) | Consul datacenter name |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace where Consul is deployed |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Helm release name for Consul |
<!-- END_TF_DOCS -->
