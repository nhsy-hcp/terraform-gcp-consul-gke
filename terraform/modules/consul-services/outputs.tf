output "services_release_name" {
  description = "Helm release name for consul-services"
  value       = var.deploy_services ? helm_release.consul_services[0].name : null
}

output "services_namespace" {
  description = "Kubernetes namespace for services"
  value       = var.services_namespace
}
