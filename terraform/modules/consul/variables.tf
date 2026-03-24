variable "namespace" {
  description = "Kubernetes namespace for Consul"
  type        = string
  default     = "consul"
}

variable "release_name" {
  description = "Helm release name for Consul"
  type        = string
  default     = "consul"
}

variable "chart_version" {
  description = "Consul Helm chart version"
  type        = string
  default     = "1.9.5"
}

variable "datacenter" {
  description = "Consul datacenter name"
  type        = string
  default     = "dc1"
}

variable "server_replicas" {
  description = "Number of Consul server replicas"
  type        = number
  default     = 3
}

variable "storage_size" {
  description = "Storage size for Consul persistent volumes"
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  description = "Storage class for Consul persistent volumes"
  type        = string
  default     = "standard-rwo"
}

variable "tls_enabled" {
  description = "Enable TLS for Consul"
  type        = bool
  default     = true
}

variable "acls_enabled" {
  description = "Enable ACLs for Consul"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = true
}

variable "enable_cni" {
  description = "Enable CNI for transparent proxy"
  type        = bool
  default     = true
}

variable "enable_ui" {
  description = "Enable Consul UI"
  type        = bool
  default     = true
}

variable "ui_service_type" {
  description = "Kubernetes service type for Consul UI"
  type        = string
  default     = "LoadBalancer"
}

variable "enable_gke_autopilot" {
  description = "Enable Consul Autopilot mode (for GKE Autopilot)"
  type        = bool
  default     = false
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}
