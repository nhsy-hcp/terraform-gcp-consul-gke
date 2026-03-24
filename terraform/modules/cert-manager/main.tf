
resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = var.namespace
  }
}

# Service account for cert-manager with Workload Identity
resource "google_service_account" "cert_manager" {
  account_id   = var.service_account_name
  display_name = "cert-manager DNS01 solver"
  project      = var.project_id
}

# Grant DNS admin role to service account
resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}

# Workload Identity binding
resource "google_service_account_iam_member" "cert_manager_workload_identity" {
  service_account_id = google_service_account.cert_manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.k8s_service_account_name}]"
}

# Kubernetes service account for cert-manager
resource "kubernetes_service_account_v1" "cert_manager" {
  metadata {
    name      = var.k8s_service_account_name
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.cert_manager.email
    }
  }
}

# Install cert-manager via Helm
resource "helm_release" "cert_manager" {
  name       = var.release_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account_v1.cert_manager.metadata[0].name
    },
    {
      name  = "global.leaderElection.namespace"
      value = kubernetes_namespace_v1.cert_manager.metadata[0].name
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.cert_manager,
    kubernetes_service_account_v1.cert_manager,
    google_service_account_iam_member.cert_manager_workload_identity
  ]
}
