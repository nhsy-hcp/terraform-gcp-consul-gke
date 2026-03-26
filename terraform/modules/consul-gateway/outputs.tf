output "gateway_release_name" {
  description = "Helm release name for consul-gateway"
  value       = var.deploy_gateway ? helm_release.consul_gateway[0].name : null
}

output "gateway_namespace" {
  description = "Kubernetes namespace for gateway"
  value       = var.gateway_namespace
}

output "apigw_lb_address" {
  description = "External IP of the API Gateway service"
  value       = var.deploy_gateway ? try(data.kubernetes_service_v1.api_gateway[0].status[0].load_balancer[0].ingress[0].ip, null) : null
}
