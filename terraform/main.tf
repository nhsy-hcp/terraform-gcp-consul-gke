# Generate random suffix for resource names
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# Data source to look up existing Cloud DNS zone
data "google_dns_managed_zone" "main" {
  name    = var.dns_zone_name
  project = var.project_id
}

# Data source to fetch available zones in the region
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

data "google_client_config" "current" {}

# Prerequisites: VPC, subnet, NAT, and API enablement
module "prereqs" {
  source = "./modules/prereqs"

  project_id    = var.project_id
  region        = var.region
  network_name  = "${var.network_name}-${local.suffix}"
  subnet_name   = "${var.subnet_name}-${local.suffix}"
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

# GKE Cluster
module "gke" {
  source = "./modules/gke"

  project_id             = var.project_id
  region                 = var.region
  cluster_name           = "${var.cluster_name}-${local.suffix}"
  suffix                 = local.suffix
  node_locations         = local.selected_zones
  network_name           = module.prereqs.network_name
  subnetwork_name        = module.prereqs.subnet_name
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  pods_range_name        = module.prereqs.pods_range_name
  services_range_name    = module.prereqs.services_range_name
  node_count_per_zone    = var.node_count_per_zone
  machine_type           = var.machine_type
  disk_size_gb           = var.disk_size_gb
  disk_type              = var.disk_type
  maintenance_start_time = var.maintenance_start_time
  authorized_networks    = local.authorized_networks
  node_labels            = var.node_labels
  node_tags              = var.node_tags
}

# Fetch current public IP for master authorized networks (only if no custom networks provided)
data "http" "mgmt_ip" {
  count = length(var.additional_authorized_networks) == 0 ? 1 : 0
  url   = "https://ipv4.icanhazip.com"
}

# Deploy Consul
module "consul" {
  source = "./modules/consul"

  project_id      = var.project_id
  cluster_name    = module.gke.cluster_name
  namespace       = var.consul_namespace
  chart_version   = var.consul_chart_version
  datacenter      = var.consul_datacenter
  server_replicas = var.consul_server_replicas
  storage_class   = var.consul_storage_class
  storage_size    = var.consul_storage_size
  acls_enabled    = var.consul_acls_enabled
  tls_enabled     = var.consul_tls_enabled
  skip_crds       = var.consul_skip_crds
  allowed_cidrs   = local.allowed_cidrs

  depends_on = [module.gke.primary_nodes_id]
}

# Deploy cert-manager
module "cert_manager" {
  source = "./modules/cert-manager"

  namespace            = var.cert_manager_namespace
  chart_version        = var.cert_manager_chart_version
  project_id           = var.project_id
  service_account_name = "${var.cert_manager_sa_name}-${local.suffix}"

  depends_on = [module.gke.primary_nodes_id]
}

# Deploy Helm charts (services and gateway)
module "helm_charts" {
  source = "./modules/helm-charts"

  deploy_services        = var.deploy_sample_services
  deploy_gateway         = var.deploy_api_gateway
  services_namespace     = var.services_namespace
  gateway_namespace      = module.consul.namespace
  backend_enabled        = var.backend_enabled
  backend_replicas       = var.backend_replicas
  frontend_enabled       = var.frontend_enabled
  frontend_replicas      = var.frontend_replicas
  intentions_enabled     = var.intentions_enabled
  apigw_fqdn             = local.apigw_fqdn
  frontend_fqdn          = local.frontend_fqdn
  backend_fqdn           = local.backend_fqdn
  consul_fqdn            = local.consul_fqdn
  project_id             = var.project_id
  cert_email             = var.cert_email
  use_production_issuer  = var.use_production_issuer
  cert_dns_names         = ["*.${local.consul_fqdn}", local.consul_fqdn]
  consul_namespace       = module.consul.namespace
  cert_manager_namespace = module.cert_manager.namespace
  allowed_cidrs          = local.allowed_cidrs

  depends_on = [module.consul, module.cert_manager]
}

# DNS Record for API Gateway (Root Domain)
resource "google_dns_record_set" "api_gateway" {
  count        = var.deploy_api_gateway ? 1 : 0
  name         = "${local.apigw_fqdn}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.main.name
  project      = var.project_id
  rrdatas      = [module.helm_charts.apigw_lb_address]
}

# Wildcard CNAME for all consul subdomains (frontend, backend, etc.) pointing to API Gateway
resource "google_dns_record_set" "consul_wildcard" {
  count        = var.deploy_api_gateway ? 1 : 0
  name         = "*.consul-${local.suffix}.${local.domain}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.main.name
  project      = var.project_id
  rrdatas      = ["${local.apigw_fqdn}."]
}

# DNS Record for Consul
resource "google_dns_record_set" "consul" {
  name         = "${local.consul_fqdn}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.main.name
  project      = var.project_id
  rrdatas      = [module.consul.consul_lb_address]
}
