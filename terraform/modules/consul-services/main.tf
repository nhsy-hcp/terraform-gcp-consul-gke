# Deploy consul-services Helm chart
resource "helm_release" "consul_services" {
  count = var.deploy_services ? 1 : 0

  name      = "consul-services"
  chart     = "${path.root}/../helm/consul-services"
  namespace = var.services_namespace

  set = [
    {
      name  = "backend.enabled"
      value = var.backend_enabled
    },
    {
      name  = "backend.replicas"
      value = var.backend_replicas
    },
    {
      name  = "frontend.enabled"
      value = var.frontend_enabled
    },
    {
      name  = "frontend.replicas"
      value = var.frontend_replicas
    },
    {
      name  = "intentions.enabled"
      value = var.intentions_enabled
    },
    {
      name  = "routes.enabled"
      value = var.deploy_gateway
    },
    {
      name  = "routes.gateway.name"
      value = "api-gateway"
    },
    {
      name  = "routes.gateway.namespace"
      value = var.gateway_namespace
    },
    {
      name  = "routes.frontend.hostname"
      value = var.frontend_fqdn
    },
    {
      name  = "routes.backend.hostname"
      value = var.backend_fqdn
    },
    {
      name  = "routes.backend.path"
      value = "/"
    }
  ]

  depends_on = [
    var.consul_namespace,
    var.gateway_release_name
  ]
}
