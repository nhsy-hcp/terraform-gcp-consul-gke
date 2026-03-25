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

variable "skip_crds" {
  description = "Skip installation of CRDs by Helm"
  type        = bool
  default     = true
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access external LoadBalancers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}
