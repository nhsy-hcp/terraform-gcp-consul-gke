# terraform

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.24 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.24.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert-manager | n/a |
| <a name="module_consul"></a> [consul](#module\_consul) | ./modules/consul | n/a |
| <a name="module_gke"></a> [gke](#module\_gke) | ./modules/gke | n/a |
| <a name="module_helm_charts"></a> [helm\_charts](#module\_helm\_charts) | ./modules/helm-charts | n/a |
| <a name="module_prereqs"></a> [prereqs](#module\_prereqs) | ./modules/prereqs | n/a |

## Resources

| Name | Type |
|------|------|
| [google_dns_record_set.api_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.frontend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_dns_managed_zone.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
| [http_http.mgmt_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_authorized_networks"></a> [additional\_authorized\_networks](#input\_additional\_authorized\_networks) | CIDR blocks for GKE master authorized networks. When empty (default), current IP is auto-detected. When specified, ONLY these networks are used (mutually exclusive with auto-detection). | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_backend_enabled"></a> [backend\_enabled](#input\_backend\_enabled) | Enable backend service | `bool` | `true` | no |
| <a name="input_backend_replicas"></a> [backend\_replicas](#input\_backend\_replicas) | Number of backend replicas | `number` | `2` | no |
| <a name="input_cert_email"></a> [cert\_email](#input\_cert\_email) | Email address for Let's Encrypt certificate notifications | `string` | n/a | yes |
| <a name="input_cert_manager_chart_version"></a> [cert\_manager\_chart\_version](#input\_cert\_manager\_chart\_version) | cert-manager Helm chart version | `string` | `"v1.14.0"` | no |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | Kubernetes namespace for cert-manager | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_sa_name"></a> [cert\_manager\_sa\_name](#input\_cert\_manager\_sa\_name) | GCP service account name for cert-manager | `string` | `"cert-manager-dns01"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster | `string` | `"consul"` | no |
| <a name="input_consul_acls_enabled"></a> [consul\_acls\_enabled](#input\_consul\_acls\_enabled) | Enable Consul ACLs | `bool` | `true` | no |
| <a name="input_consul_chart_version"></a> [consul\_chart\_version](#input\_consul\_chart\_version) | Consul Helm chart version | `string` | `"1.9.5"` | no |
| <a name="input_consul_datacenter"></a> [consul\_datacenter](#input\_consul\_datacenter) | Consul datacenter name | `string` | `"dc1"` | no |
| <a name="input_consul_namespace"></a> [consul\_namespace](#input\_consul\_namespace) | Kubernetes namespace for Consul | `string` | `"consul"` | no |
| <a name="input_consul_server_replicas"></a> [consul\_server\_replicas](#input\_consul\_server\_replicas) | Number of Consul server replicas | `number` | `3` | no |
| <a name="input_consul_skip_crds"></a> [consul\_skip\_crds](#input\_consul\_skip\_crds) | Skip installation of CRDs by Helm | `bool` | `true` | no |
| <a name="input_consul_storage_class"></a> [consul\_storage\_class](#input\_consul\_storage\_class) | Storage class for Consul server persistent volumes | `string` | `"standard-rwo"` | no |
| <a name="input_consul_storage_size"></a> [consul\_storage\_size](#input\_consul\_storage\_size) | Storage size for Consul server persistent volumes | `string` | `"10Gi"` | no |
| <a name="input_consul_tls_enabled"></a> [consul\_tls\_enabled](#input\_consul\_tls\_enabled) | Enable TLS for Consul | `bool` | `true` | no |
| <a name="input_deploy_api_gateway"></a> [deploy\_api\_gateway](#input\_deploy\_api\_gateway) | Deploy API Gateway with TLS configuration | `bool` | `true` | no |
| <a name="input_deploy_sample_services"></a> [deploy\_sample\_services](#input\_deploy\_sample\_services) | Deploy sample backend and frontend services | `bool` | `true` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Disk size in GB for GKE nodes | `number` | `100` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for GKE nodes | `string` | `"pd-standard"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Name of the existing Cloud DNS managed zone | `string` | n/a | yes |
| <a name="input_frontend_enabled"></a> [frontend\_enabled](#input\_frontend\_enabled) | Enable frontend service | `bool` | `true` | no |
| <a name="input_frontend_replicas"></a> [frontend\_replicas](#input\_frontend\_replicas) | Number of frontend replicas | `number` | `2` | no |
| <a name="input_intentions_enabled"></a> [intentions\_enabled](#input\_intentions\_enabled) | Enable service intentions (authorization rules) | `bool` | `true` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for GKE nodes | `string` | `"e2-standard-4"` | no |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | Start time for daily maintenance window (HH:MM format) | `string` | `"03:00"` | no |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The IP range in CIDR notation to use for the hosted master network | `string` | `"172.16.0.0/28"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the VPC network to create | `string` | `"net"` | no |
| <a name="input_node_count_per_zone"></a> [node\_count\_per\_zone](#input\_node\_count\_per\_zone) | Number of nodes per zone | `number` | `1` | no |
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels) | Labels to apply to GKE nodes | `map(string)` | `{}` | no |
| <a name="input_node_tags"></a> [node\_tags](#input\_node\_tags) | Network tags to apply to GKE nodes | `list(string)` | `[]` | no |
| <a name="input_num_zones"></a> [num\_zones](#input\_num\_zones) | Number of zones to use for the regional cluster nodes | `number` | `3` | no |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | CIDR range for GKE pods (secondary range) - 10.64.64.0 to 10.64.127.255 | `string` | `"10.64.64.0/18"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for the GKE cluster | `string` | `"europe-west1"` | no |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | CIDR range for GKE services (secondary range) - 10.64.4.0 to 10.64.7.255 | `string` | `"10.64.4.0/22"` | no |
| <a name="input_services_namespace"></a> [services\_namespace](#input\_services\_namespace) | Kubernetes namespace for sample services | `string` | `"default"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR range for the subnet (nodes) - 10.64.0.0 to 10.64.3.255 | `string` | `"10.64.0.0/22"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet to create | `string` | `"snet"` | no |
| <a name="input_use_production_issuer"></a> [use\_production\_issuer](#input\_use\_production\_issuer) | Use Let's Encrypt production issuer (set to false for staging during testing) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_backend_url"></a> [api\_gateway\_backend\_url](#output\_api\_gateway\_backend\_url) | URL for the sample backend service |
| <a name="output_api_gateway_frontend_url"></a> [api\_gateway\_frontend\_url](#output\_api\_gateway\_frontend\_url) | URL for the sample frontend service |
| <a name="output_apigw_lb_address"></a> [apigw\_lb\_address](#output\_apigw\_lb\_address) | External IP of the API Gateway |
| <a name="output_authorized_networks"></a> [authorized\_networks](#output\_authorized\_networks) | Authorized networks configured for GKE master access |
| <a name="output_cert_manager_namespace"></a> [cert\_manager\_namespace](#output\_cert\_manager\_namespace) | Kubernetes namespace where cert-manager is deployed |
| <a name="output_cert_manager_release_name"></a> [cert\_manager\_release\_name](#output\_cert\_manager\_release\_name) | Helm release name for cert-manager |
| <a name="output_cert_manager_service_account"></a> [cert\_manager\_service\_account](#output\_cert\_manager\_service\_account) | GCP service account email for cert-manager |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | GKE cluster CA certificate |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | GKE cluster endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | GKE cluster name |
| <a name="output_consul_chart_version"></a> [consul\_chart\_version](#output\_consul\_chart\_version) | Consul Helm chart version |
| <a name="output_consul_datacenter"></a> [consul\_datacenter](#output\_consul\_datacenter) | Consul datacenter name |
| <a name="output_consul_fqdn"></a> [consul\_fqdn](#output\_consul\_fqdn) | FQDN for the API Gateway (Root) |
| <a name="output_consul_lb_address"></a> [consul\_lb\_address](#output\_consul\_lb\_address) | External IP of the Consul UI |
| <a name="output_consul_namespace"></a> [consul\_namespace](#output\_consul\_namespace) | Kubernetes namespace where Consul is deployed |
| <a name="output_consul_release_name"></a> [consul\_release\_name](#output\_consul\_release\_name) | Helm release name for Consul |
| <a name="output_consul_ui_url"></a> [consul\_ui\_url](#output\_consul\_ui\_url) | FQDN for the Consul UI |
| <a name="output_dns_zone_dns_name"></a> [dns\_zone\_dns\_name](#output\_dns\_zone\_dns\_name) | Cloud DNS managed zone DNS name |
| <a name="output_dns_zone_name"></a> [dns\_zone\_name](#output\_dns\_zone\_name) | Cloud DNS managed zone name |
| <a name="output_gateway_release_name"></a> [gateway\_release\_name](#output\_gateway\_release\_name) | Helm release name for consul-gateway |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC network name |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | VPC network self link |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP project ID |
| <a name="output_region"></a> [region](#output\_region) | GCP region |
| <a name="output_resource_suffix"></a> [resource\_suffix](#output\_resource\_suffix) | Random suffix applied to all GCP resource names for uniqueness |
| <a name="output_services_release_name"></a> [services\_release\_name](#output\_services\_release\_name) | Helm release name for consul-services |
| <a name="output_subnet_cidr"></a> [subnet\_cidr](#output\_subnet\_cidr) | Subnet CIDR range |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Subnet name |
<!-- END_TF_DOCS -->
