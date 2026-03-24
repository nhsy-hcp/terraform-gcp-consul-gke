# cert-manager

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
| [google_project_iam_member.cert_manager_dns_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.cert_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.cert_manager_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_service_account_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | cert-manager Helm chart version | `string` | `"v1.14.0"` | no |
| <a name="input_k8s_service_account_name"></a> [k8s\_service\_account\_name](#input\_k8s\_service\_account\_name) | Kubernetes service account name for cert-manager | `string` | `"cert-manager"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for cert-manager | `string` | `"cert-manager"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name for cert-manager | `string` | `"cert-manager"` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | GCP service account name for cert-manager | `string` | `"cert-manager-dns01"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | cert-manager Helm chart version |
| <a name="output_k8s_service_account_name"></a> [k8s\_service\_account\_name](#output\_k8s\_service\_account\_name) | Kubernetes service account name for cert-manager |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace where cert-manager is deployed |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Helm release name for cert-manager |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | GCP service account email for cert-manager |
<!-- END_TF_DOCS -->
