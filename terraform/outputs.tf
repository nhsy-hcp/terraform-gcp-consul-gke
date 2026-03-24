# ============================================================================
# Resource Naming
# ============================================================================

output "resource_suffix" {
  description = "Random suffix applied to all GCP resource names for uniqueness"
  value       = local.suffix
}

# ============================================================================
# Network Outputs
# ============================================================================

output "network_name" {
  description = "VPC network name"
  value       = module.prereqs.network_name
}

output "network_self_link" {
  description = "VPC network self link"
  value       = module.prereqs.network_self_link
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.prereqs.subnet_name
}

output "subnet_cidr" {
  description = "Subnet CIDR range"
  value       = module.prereqs.subnet_cidr
}

output "region" {
  description = "GCP region"
  value       = module.prereqs.region
}

output "authorized_networks" {
  description = "Authorized networks configured for GKE master access"
  value       = local.authorized_networks
}

# ============================================================================
# GKE Cluster Outputs
# ============================================================================

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "project_id" {
  description = "GCP project ID"
  value       = module.gke.project_id
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

# ============================================================================
# Consul Outputs
# ============================================================================

output "consul_namespace" {
  description = "Kubernetes namespace where Consul is deployed"
  value       = module.consul.namespace
}

output "consul_release_name" {
  description = "Helm release name for Consul"
  value       = module.consul.release_name
}

output "consul_chart_version" {
  description = "Consul Helm chart version"
  value       = module.consul.chart_version
}

output "consul_datacenter" {
  description = "Consul datacenter name"
  value       = module.consul.datacenter
}

# ============================================================================
# cert-manager Outputs
# ============================================================================

output "cert_manager_namespace" {
  description = "Kubernetes namespace where cert-manager is deployed"
  value       = module.cert_manager.namespace
}

output "cert_manager_release_name" {
  description = "Helm release name for cert-manager"
  value       = module.cert_manager.release_name
}

output "cert_manager_service_account" {
  description = "GCP service account email for cert-manager"
  value       = module.cert_manager.service_account_email
}

# ============================================================================
# Helm Charts Outputs
# ============================================================================

output "services_release_name" {
  description = "Helm release name for consul-services"
  value       = module.helm_charts.services_release_name
}

output "gateway_release_name" {
  description = "Helm release name for consul-gateway"
  value       = module.helm_charts.gateway_release_name
}

# ============================================================================
# DNS Outputs
# ============================================================================

output "dns_zone_name" {
  description = "Cloud DNS managed zone name"
  value       = data.google_dns_managed_zone.main.name
}

output "dns_zone_dns_name" {
  description = "Cloud DNS managed zone DNS name"
  value       = data.google_dns_managed_zone.main.dns_name
}
