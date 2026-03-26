# Deploy consul-gateway Helm chart
resource "helm_release" "consul_gateway" {
  count = var.deploy_gateway ? 1 : 0

  name      = "consul-gateway"
  chart     = "${path.root}/../helm/consul-gateway"
  namespace = var.gateway_namespace

  # Force recreation on hostname changes
  recreate_pods = true

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
        value = "*.${var.consul_fqdn}"
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
      for idx, dns_name in var.cert_dns_names : {
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
