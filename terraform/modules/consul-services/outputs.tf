output "services_release_name" {
  description = "Helm release name for consul-services"
  value       = var.deploy_services ? helm_release.consul_services[0].name : null
}

output "demo_namespace" {
  description = "Kubernetes namespace for demo application services"
  value       = var.demo_namespace
}
