# prereqs

<!-- BEGIN_TF_DOCS -->
Prerequisites Module

This module sets up the foundational GCP infrastructure:
- Enables required GCP APIs
- Creates VPC network with subnet
- Configures Cloud NAT for private GKE nodes

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
| [google_compute_firewall.allow_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.gke_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the VPC network | `string` | `"net"` | no |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | CIDR range for GKE pods | `string` | `"10.64.64.0/18"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for resources | `string` | `"europe-west1"` | no |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | CIDR range for GKE services | `string` | `"10.64.4.0/22"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR range for the subnet | `string` | `"10.64.0.0/22"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet | `string` | `"snet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_name"></a> [nat\_name](#output\_nat\_name) | The name of the Cloud NAT |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | The ID of the VPC network |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | The name of the VPC network |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | The self link of the VPC network |
| <a name="output_pods_range_name"></a> [pods\_range\_name](#output\_pods\_range\_name) | The name of the secondary IP range for pods |
| <a name="output_region"></a> [region](#output\_region) | The region where resources are created |
| <a name="output_router_name"></a> [router\_name](#output\_router\_name) | The name of the Cloud Router |
| <a name="output_services_range_name"></a> [services\_range\_name](#output\_services\_range\_name) | The name of the secondary IP range for services |
| <a name="output_subnet_cidr"></a> [subnet\_cidr](#output\_subnet\_cidr) | The CIDR range of the subnet |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the subnet |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the subnet |
| <a name="output_subnet_self_link"></a> [subnet\_self\_link](#output\_subnet\_self\_link) | The self link of the subnet |
<!-- END_TF_DOCS -->
