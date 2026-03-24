# ============================================================================
# GCP Project Configuration
# ============================================================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the GKE cluster"
  type        = string
  default     = "europe-west1"
}

# ============================================================================
# GKE Cluster Configuration
# ============================================================================

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "consul-mesh"
}

variable "num_zones" {
  description = "Number of zones to use for the regional cluster nodes"
  type        = number
  default     = 3
}

variable "node_count_per_zone" {
  description = "Number of nodes per zone"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "node_labels" {
  description = "Labels to apply to GKE nodes"
  type        = map(string)
  default     = {}
}

variable "node_tags" {
  description = "Network tags to apply to GKE nodes"
  type        = list(string)
  default     = []
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "network_name" {
  description = "Name of the VPC network to create"
  type        = string
  default     = "consul-gke-network"
}

variable "subnet_name" {
  description = "Name of the subnet to create"
  type        = string
  default     = "consul-gke-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet (nodes) - 10.64.0.0 to 10.64.3.255"
  type        = string
  default     = "10.64.0.0/22"
}

variable "pods_cidr" {
  description = "CIDR range for GKE pods (secondary range) - 10.64.64.0 to 10.64.127.255"
  type        = string
  default     = "10.64.64.0/18"
}

variable "services_cidr" {
  description = "CIDR range for GKE services (secondary range) - 10.64.4.0 to 10.64.7.255"
  type        = string
  default     = "10.64.4.0/22"
}

# ============================================================================
# Maintenance Configuration
# ============================================================================

variable "maintenance_start_time" {
  description = "Start time for daily maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "additional_authorized_networks" {
  description = "CIDR blocks for GKE master authorized networks. When empty (default), current IP is auto-detected. When specified, ONLY these networks are used (mutually exclusive with auto-detection)."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# ============================================================================
# Consul Configuration
# ============================================================================

variable "consul_namespace" {
  description = "Kubernetes namespace for Consul"
  type        = string
  default     = "consul"
}

variable "consul_chart_version" {
  description = "Consul Helm chart version"
  type        = string
  default     = "1.9.5"
}

variable "consul_datacenter" {
  description = "Consul datacenter name"
  type        = string
  default     = "dc1"
}

variable "consul_server_replicas" {
  description = "Number of Consul server replicas"
  type        = number
  default     = 3
}

variable "consul_storage_class" {
  description = "Storage class for Consul server persistent volumes"
  type        = string
  default     = "standard-rwo"
}

variable "consul_storage_size" {
  description = "Storage size for Consul server persistent volumes"
  type        = string
  default     = "10Gi"
}

variable "enable_gke_autopilot" {
  description = "Enable Consul Autopilot mode (for GKE Autopilot)"
  type        = bool
  default     = false
}

variable "consul_enable_cni" {
  description = "Enable CNI plugin for transparent proxy"
  type        = bool
  default     = true
}

variable "consul_enable_prometheus" {
  description = "Deploy a Prometheus instance for monitoring"
  type        = bool
  default     = true
}

variable "consul_enable_ui" {
  description = "Enable Consul UI"
  type        = bool
  default     = true
}

variable "consul_ui_service_type" {
  description = "Kubernetes service type for Consul UI"
  type        = string
  default     = "LoadBalancer"
}

variable "consul_enable_transparent_proxy" {
  description = "Enable transparent proxy for service mesh"
  type        = bool
  default     = true
}

variable "consul_enable_controller" {
  description = "Enable Consul controller for CRD management"
  type        = bool
  default     = true
}

variable "consul_acls_enabled" {
  description = "Enable Consul ACLs"
  type        = bool
  default     = true
}

variable "consul_tls_enabled" {
  description = "Enable TLS for Consul"
  type        = bool
  default     = true
}

# ============================================================================
# cert-manager Configuration
# ============================================================================

variable "cert_manager_namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "v1.14.0"
}

variable "cert_manager_sa_name" {
  description = "GCP service account name for cert-manager"
  type        = string
  default     = "cert-manager-dns01"
}

# ============================================================================
# DNS and TLS Configuration
# ============================================================================

variable "dns_zone_name" {
  description = "Name of the existing Cloud DNS managed zone"
  type        = string
}

variable "apigw_prefix" {
  description = "Prefix to append to the DNS zone domain (e.g., 'app' for 'app.example.com')"
  type        = string
  default     = "app"
}

variable "cert_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
}

variable "use_production_issuer" {
  description = "Use Let's Encrypt production issuer (set to false for staging during testing)"
  type        = bool
  default     = false
}

variable "cert_dns_names" {
  description = "DNS names for the certificate (defaults to domain and wildcard)"
  type        = list(string)
  default     = []
}

# ============================================================================
# Sample Services Configuration
# ============================================================================

variable "deploy_sample_services" {
  description = "Deploy sample backend and frontend services"
  type        = bool
  default     = true
}

variable "deploy_api_gateway" {
  description = "Deploy API Gateway with TLS configuration"
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
  description = "Enable service intentions (authorization rules)"
  type        = bool
  default     = true
}
