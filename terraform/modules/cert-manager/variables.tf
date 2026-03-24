variable "namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "release_name" {
  description = "Helm release name for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "v1.14.0"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_account_name" {
  description = "GCP service account name for cert-manager"
  type        = string
  default     = "cert-manager-dns01"
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name for cert-manager"
  type        = string
  default     = "cert-manager"
}
