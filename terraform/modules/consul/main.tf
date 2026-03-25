
resource "kubernetes_namespace_v1" "consul" {
  metadata {
    name = var.namespace
  }
}

# GCP Service Account for Consul Server
resource "google_service_account" "consul_server" {
  account_id   = "consul-server-${substr(var.cluster_name, -4, 4)}"
  display_name = "Consul Server Service Account for ${var.cluster_name}"
  project      = var.project_id
}

# Workload Identity Binding
resource "google_service_account_iam_member" "consul_server_workload_identity" {
  service_account_id = google_service_account.consul_server.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/consul-server]"

  depends_on = [kubernetes_namespace_v1.consul]
}

resource "helm_release" "consul" {
  name       = var.release_name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.consul.metadata[0].name
  skip_crds  = var.skip_crds

  values = [
    templatefile("${path.module}/../../templates/consul-values.yaml.tpl", {
      datacenter       = var.datacenter
      replicas         = var.server_replicas
      bootstrap_expect = var.server_replicas
      storage_size     = var.storage_size
      storage_class    = var.storage_class
      enable_tls       = var.tls_enabled
      enable_acls      = var.acls_enabled
      server_iam_sa    = google_service_account.consul_server.email
      manage_crds      = !var.skip_crds
      allowed_cidrs    = jsonencode(var.allowed_cidrs)
    })
  ]


  timeout = 600

  depends_on = [kubernetes_namespace_v1.consul]
}
