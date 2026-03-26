variable "deploy_services" {
  description = "Deploy sample services (backend and frontend)"
  type        = bool
  default     = true
}

variable "services_namespace" {
  description = "Kubernetes namespace for sample services"
  type        = string
  default     = "default"
}

variable "backend_enabled" {
  description = "Enable backend service"
  type        = bool
  default     = true
}

variable "backend_replicas" {
  description = "Number of backend replicas"
  type        = number
  default     = 2
}

variable "frontend_enabled" {
  description = "Enable frontend service"
  type        = bool
  default     = true
}

variable "frontend_replicas" {
  description = "Number of frontend replicas"
  type        = number
  default     = 2
}

variable "intentions_enabled" {
  description = "Enable service intentions"
  type        = bool
  default     = true
}

variable "deploy_gateway" {
  description = "Enable routes in the gateway"
  type        = bool
  default     = true
}

variable "gateway_namespace" {
  description = "Kubernetes namespace for API Gateway"
  type        = string
  default     = "consul"
}

variable "frontend_fqdn" {
  description = "Fully Qualified Domain Name for the Frontend service"
  type        = string
}

variable "backend_fqdn" {
  description = "Fully Qualified Domain Name for the Backend service"
  type        = string
}

variable "consul_namespace" {
  description = "Consul namespace dependency"
  type        = string
}

variable "gateway_release_name" {
  description = "Gateway release name dependency"
  type        = string
  default     = ""
}
