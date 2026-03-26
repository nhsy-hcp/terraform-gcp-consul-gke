output "namespace" {
  description = "Kubernetes namespace where cert-manager is deployed"
  value       = kubernetes_namespace_v1.cert_manager.metadata[0].name
}

output "release_name" {
  description = "Helm release name for cert-manager"
  value       = helm_release.cert_manager.name
}

output "chart_version" {
  description = "cert-manager Helm chart version"
  value       = helm_release.cert_manager.version
}

output "service_account_email" {
  description = "GCP service account email for cert-manager"
  value       = google_service_account.cert_manager.email
}

output "k8s_service_account_name" {
  description = "Kubernetes service account name for cert-manager"
  value       = kubernetes_service_account_v1.cert_manager.metadata[0].name
}

output "cert_manager_ready" {
  description = "Dependency anchor - cert-manager is fully deployed and ready"
  value       = null_resource.wait_for_cert_manager.id
}
