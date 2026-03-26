variable "deploy_gateway" {
  description = "Deploy API Gateway with TLS"
  type        = bool
  default     = true
}

variable "gateway_namespace" {
  description = "Kubernetes namespace for API Gateway"
  type        = string
  default     = "consul"
}

variable "apigw_fqdn" {
  description = "Fully Qualified Domain Name for the API Gateway"
  type        = string
}

variable "consul_fqdn" {
  description = "Fully Qualified Domain Name for Consul"
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
