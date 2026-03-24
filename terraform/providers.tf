provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

# Configure Helm provider
provider "helm" {
  repository_config_path = "${path.root}/.tmp/helm/repositories.yaml"
  repository_cache       = "${path.root}/.tmp/helm/cache"
  kubernetes = {
    host                   = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}
