output "namespace" {
  description = "Kubernetes namespace where Consul is deployed"
  value       = kubernetes_namespace_v1.consul.metadata[0].name
}

output "release_name" {
  description = "Helm release name for Consul"
  value       = helm_release.consul.name
}

output "chart_version" {
  description = "Consul Helm chart version"
  value       = helm_release.consul.version
}

output "datacenter" {
  description = "Consul datacenter name"
  value       = var.datacenter
}

output "consul_ui_ip" {
  description = "External IP of the Consul UI service"
  value       = data.kubernetes_service_v1.consul_ui.status[0].load_balancer[0].ingress[0].ip
}
