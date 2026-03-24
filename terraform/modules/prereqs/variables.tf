variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "consul-gke-network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "consul-gke-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.64.0.0/22"
}

variable "pods_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
  default     = "10.64.64.0/18"
}

variable "services_cidr" {
  description = "CIDR range for GKE services"
  type        = string
  default     = "10.64.4.0/22"
}
