variable "deploy_services" {
  description = "Deploy sample services (api and web)"
  type        = bool
  default     = true
}

variable "demo_namespace" {
  description = "Kubernetes namespace for demo application services"
  type        = string
  default     = "demo"
}

variable "api_enabled" {
  description = "Enable API service"
  type        = bool
  default     = true
}

variable "api_replicas" {
  description = "Number of API replicas"
  type        = number
  default     = 2
}

variable "web_enabled" {
  description = "Enable Web UI service"
  type        = bool
  default     = true
}

variable "web_replicas" {
  description = "Number of Web UI replicas"
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

variable "demo_fqdn" {
  description = "Fully Qualified Domain Name for the demo application (shared by web and api)"
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

variable "pod_readiness_timeout" {
  description = "Timeout in seconds for waiting for service pods to be ready"
  type        = number
  default     = 120
}
