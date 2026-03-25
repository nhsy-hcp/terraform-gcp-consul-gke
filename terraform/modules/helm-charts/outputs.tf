output "services_release_name" {
  description = "Helm release name for consul-services"
  value       = var.deploy_services ? helm_release.consul_services[0].name : null
}

output "gateway_release_name" {
  description = "Helm release name for consul-gateway"
  value       = var.deploy_gateway ? helm_release.consul_gateway[0].name : null
}

output "services_namespace" {
  description = "Kubernetes namespace for services"
  value       = var.services_namespace
}

output "gateway_namespace" {
  description = "Kubernetes namespace for gateway"
  value       = var.gateway_namespace
}

output "api_gateway_ip" {
  description = "External IP of the API Gateway service"
  value       = var.deploy_gateway ? data.kubernetes_service_v1.api_gateway[0].status[0].load_balancer[0].ingress[0].ip : null
}
