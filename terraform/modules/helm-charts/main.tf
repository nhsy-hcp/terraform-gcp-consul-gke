
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
    }
  ]

  depends_on = [var.consul_namespace]
}

# Deploy consul-gateway Helm chart
resource "helm_release" "consul_gateway" {
  count = var.deploy_gateway ? 1 : 0

  name      = "consul-gateway"
  chart     = "${path.root}/../helm/consul-gateway"
  namespace = var.gateway_namespace

  set = concat(
    [
      {
        name  = "global.domain"
        value = var.apigw_fqdn
      },
      {
        name  = "global.projectId"
        value = var.project_id
      },
      {
        name  = "gateway.https.hostname"
        value = var.apigw_fqdn
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
        name  = "tls.clusterIssuer.staging.enabled"
        value = !var.use_production_issuer
      },
      {
        name  = "tls.clusterIssuer.production.enabled"
        value = var.use_production_issuer
      },
      {
        name  = "tls.clusterIssuer.staging.email"
        value = var.cert_email
      },
      {
        name  = "tls.clusterIssuer.production.email"
        value = var.cert_email
      },
      {
        name  = "tls.certificate.issuerName"
        value = var.use_production_issuer ? "letsencrypt-prod" : "letsencrypt-staging"
      }
    ],
    [
      for idx, cidr in var.allowed_cidrs : {
        name  = "gateway.loadBalancerSourceRanges[${idx}]"
        value = cidr
      }
    ],
    [
      for idx, dns_name in(length(var.cert_dns_names) > 0 ? var.cert_dns_names : [var.apigw_fqdn, var.frontend_fqdn, var.backend_fqdn, "*.consul-${split("-", split(".", var.apigw_fqdn)[1])[1]}.${join(".", slice(split(".", var.apigw_fqdn), 2, length(split(".", var.apigw_fqdn))))}"]) : {
        name  = "tls.certificate.dnsNames[${idx}]"
        value = dns_name
      }
    ]
  )

  depends_on = [var.consul_namespace, var.cert_manager_namespace]
}

# Data source to fetch the external IP of the API Gateway service
data "kubernetes_service_v1" "api_gateway" {
  count = var.deploy_gateway ? 1 : 0
  metadata {
    name      = "api-gateway"
    namespace = var.gateway_namespace
  }
  depends_on = [helm_release.consul_gateway]
}
