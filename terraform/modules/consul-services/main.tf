# Deploy consul-services Helm chart
resource "helm_release" "consul_services" {
  count = var.deploy_services ? 1 : 0

  name             = "consul-services"
  chart            = "${path.root}/../helm/consul-services"
  namespace        = var.demo_namespace
  create_namespace = true

  set = [
    {
      name  = "global.namespace"
      value = var.demo_namespace
    },
    {
      name  = "global.consulNamespace"
      value = var.consul_namespace
    },
    {
      name  = "api.enabled"
      value = var.api_enabled
    },
    {
      name  = "api.replicas"
      value = var.api_replicas
    },
    {
      name  = "web.enabled"
      value = var.web_enabled
    },
    {
      name  = "web.replicas"
      value = var.web_replicas
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
      name  = "routes.web.hostname"
      value = var.demo_fqdn
    },
    {
      name  = "routes.web.path"
      value = "/"
    },
    {
      name  = "routes.api.hostname"
      value = var.demo_fqdn
    },
    {
      name  = "routes.api.path"
      value = "/api"
    }
  ]

  depends_on = [
    var.consul_namespace,
    var.gateway_release_name
  ]
}
