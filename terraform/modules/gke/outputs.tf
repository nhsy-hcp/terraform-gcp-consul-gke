output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "endpoint" {
  description = "GKE cluster endpoint (IP)"
  value       = google_container_cluster.primary.endpoint
}

output "dns_endpoint" {
  description = "GKE cluster DNS endpoint"
  value       = try(google_container_cluster.primary.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint, google_container_cluster.primary.endpoint)
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "project_id" {
  description = "GCP project ID"
  value       = google_container_cluster.primary.project
}

output "primary_nodes_id" {
  description = "ID of the primary node pool"
  value       = google_container_node_pool.primary_nodes.id
}
