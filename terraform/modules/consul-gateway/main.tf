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
        name  = "tls.clusterIssuer.staging.enabled"
        value = !var.use_production_issuer
      },
      {
        name  = "tls.clusterIssuer.production.enabled"
        value = var.use_production_issuer
      },
      {
        name  = "tls.clusterIssuer.email"
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

# Wait for LoadBalancer IP to be assigned
resource "null_resource" "wait_for_lb_ip" {
  count = var.deploy_gateway ? 1 : 0

  provisioner "local-exec" {
    command     = "bash ${path.root}/../scripts/wait-for-lb-ip.sh ${var.gateway_namespace} 120"
    interpreter = ["bash", "-c"]
  }

  depends_on = [helm_release.consul_gateway]

  triggers = {
    # Re-run if gateway is recreated
    gateway_release = var.deploy_gateway ? helm_release.consul_gateway[0].id : ""
  }
}

# Wait for TLS secret to be populated with certificate data
resource "null_resource" "wait_for_tls_secret" {
  count = var.deploy_gateway ? 1 : 0

  provisioner "local-exec" {
    command     = "bash ${path.root}/../scripts/wait-for-tls-secret.sh ${var.gateway_namespace} api-gateway-tls"
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    helm_release.consul_gateway,
    null_resource.wait_for_lb_ip
  ]

  triggers = {
    # Re-run if gateway is recreated
    gateway_release = var.deploy_gateway ? helm_release.consul_gateway[0].id : ""
  }
}

# Wait for Certificate resource to be Ready
resource "null_resource" "wait_for_certificate" {
  count = var.deploy_gateway ? 1 : 0

  provisioner "local-exec" {
    command     = "bash ${path.root}/../scripts/wait-for-certificate.sh ${var.gateway_namespace} api-gateway-cert ${var.certificate_timeout}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    helm_release.consul_gateway,
    null_resource.wait_for_lb_ip,
    null_resource.wait_for_tls_secret
  ]

  triggers = {
    # Re-run if gateway is recreated
    gateway_release = var.deploy_gateway ? helm_release.consul_gateway[0].id : ""
  }
}

# Wait for Gateway to be programmed and listener to be accepted
resource "null_resource" "wait_for_gateway_ready" {
  count = var.deploy_gateway ? 1 : 0

  provisioner "local-exec" {
    command     = "bash ${path.root}/../scripts/wait-for-gateway-ready.sh ${var.gateway_namespace} api-gateway 600"
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    helm_release.consul_gateway,
    null_resource.wait_for_lb_ip,
    null_resource.wait_for_tls_secret,
    null_resource.wait_for_certificate
  ]

  triggers = {
    # Re-run if gateway is recreated
    gateway_release = var.deploy_gateway ? helm_release.consul_gateway[0].id : ""
  }
}

# Data source to fetch the external IP of the API Gateway service
data "kubernetes_service_v1" "api_gateway" {
  count = var.deploy_gateway ? 1 : 0
  metadata {
    name      = "api-gateway"
    namespace = var.gateway_namespace
  }
  depends_on = [
    helm_release.consul_gateway,
    null_resource.wait_for_lb_ip,
    null_resource.wait_for_tls_secret,
    null_resource.wait_for_certificate,
    null_resource.wait_for_gateway_ready
  ]
}
