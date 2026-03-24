# gke

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.primary_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorized_networks"></a> [authorized\_networks](#input\_authorized\_networks) | List of authorized networks for master access | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster | `string` | n/a | yes |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Disk size in GB for GKE nodes | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for GKE nodes | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for GKE nodes | `string` | n/a | yes |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | Start time for daily maintenance window (HH:MM format) | `string` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The IP range in CIDR notation to use for the hosted master network | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | VPC network name | `string` | n/a | yes |
| <a name="input_node_count_per_zone"></a> [node\_count\_per\_zone](#input\_node\_count\_per\_zone) | Number of nodes per zone | `number` | n/a | yes |
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels) | Labels to apply to GKE nodes | `map(string)` | `{}` | no |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | Zones for the regional cluster | `list(string)` | n/a | yes |
| <a name="input_node_tags"></a> [node\_tags](#input\_node\_tags) | Network tags to apply to GKE nodes | `list(string)` | `[]` | no |
| <a name="input_pods_range_name"></a> [pods\_range\_name](#input\_pods\_range\_name) | Secondary range name for pods | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_services_range_name"></a> [services\_range\_name](#input\_services\_range\_name) | Secondary range name for services | `string` | n/a | yes |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | VPC subnetwork name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | GKE cluster CA certificate |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the GKE cluster |
| <a name="output_dns_endpoint"></a> [dns\_endpoint](#output\_dns\_endpoint) | GKE cluster DNS endpoint |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | GKE cluster endpoint (IP) |
| <a name="output_primary_nodes_id"></a> [primary\_nodes\_id](#output\_primary\_nodes\_id) | ID of the primary node pool |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP project ID |
<!-- END_TF_DOCS -->
