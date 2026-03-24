
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

  values = [
    templatefile("${path.module}/../../templates/consul-values.yaml.tpl", {
      datacenter               = var.datacenter
      replicas                 = var.server_replicas
      bootstrap_expect         = var.server_replicas
      storage_size             = var.storage_size
      storage_class            = var.storage_class
      enable_tls               = var.tls_enabled
      enable_acls              = var.acls_enabled
      enable_metrics           = var.enable_metrics
      enable_cni               = var.enable_cni
      enable_ui                = var.enable_ui
      ui_service_type          = var.ui_service_type
      api_gateway_service_type = "LoadBalancer" # Hardcode or add to variables
      enable_gke_autopilot     = var.enable_gke_autopilot
      gcp_project_id           = var.project_id
      server_iam_sa            = google_service_account.consul_server.email
    })
  ]


  timeout = 600

  depends_on = [kubernetes_namespace_v1.consul]
}
