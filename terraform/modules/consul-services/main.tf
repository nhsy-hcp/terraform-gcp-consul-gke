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

# Wait for API service pods to be ready
resource "null_resource" "wait_for_api_pods" {
  count = var.deploy_services && var.api_enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "kubectl wait --for=condition=ready pod -l app=api -n ${var.demo_namespace} --timeout=${var.pod_readiness_timeout}s || echo '⚠ API pod not ready'"
    interpreter = ["bash", "-c"]
  }

  depends_on = [helm_release.consul_services]

  triggers = {
    # Re-run if services release is recreated
    services_release = var.deploy_services ? helm_release.consul_services[0].id : ""
  }
}

# Wait for Web service pods to be ready
resource "null_resource" "wait_for_web_pods" {
  count = var.deploy_services && var.web_enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "kubectl wait --for=condition=ready pod -l app=web -n ${var.demo_namespace} --timeout=${var.pod_readiness_timeout}s || echo '⚠ Web pod not ready'"
    interpreter = ["bash", "-c"]
  }

  depends_on = [helm_release.consul_services]

  triggers = {
    # Re-run if services release is recreated
    services_release = var.deploy_services ? helm_release.consul_services[0].id : ""
  }
}
