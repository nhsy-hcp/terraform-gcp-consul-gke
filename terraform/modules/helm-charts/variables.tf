variable "deploy_services" {
  description = "Deploy sample services (backend and frontend)"
  type        = bool
  default     = true
}

variable "deploy_gateway" {
  description = "Deploy API Gateway with TLS"
  type        = bool
  default     = true
}

variable "services_namespace" {
  description = "Kubernetes namespace for sample services"
  type        = string
  default     = "default"
}

variable "gateway_namespace" {
  description = "Kubernetes namespace for API Gateway"
  type        = string
  default     = "consul"
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

variable "apigw_fqdn" {
  description = "Fully Qualified Domain Name for the API Gateway"
  type        = string
}

variable "consul_fqdn" {
  description = "Fully Qualified Domain Name for Consul"
  type        = string
}

variable "frontend_fqdn" {
  description = "Fully Qualified Domain Name for the Frontend service"
  type        = string
}

variable "backend_fqdn" {
  description = "Fully Qualified Domain Name for the Backend service"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cert_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
}

variable "use_production_issuer" {
  description = "Use Let's Encrypt production issuer (set to false for staging)"
  type        = bool
  default     = false
}

variable "cert_dns_names" {
  description = "DNS names for the certificate"
  type        = list(string)
  default     = []
}

variable "consul_namespace" {
  description = "Consul namespace dependency"
  type        = string
}

variable "cert_manager_namespace" {
  description = "cert-manager namespace dependency"
  type        = string
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access external LoadBalancers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
