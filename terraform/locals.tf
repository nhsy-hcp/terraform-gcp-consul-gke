locals {
  suffix = random_string.suffix.result
  domain = trimsuffix(data.google_dns_managed_zone.main.dns_name, ".")
  # Calculate FQDNs
  apigw_fqdn    = "apigw.consul-${local.suffix}.${local.domain}"
  frontend_fqdn = "frontend.consul-${local.suffix}.${local.domain}"
  backend_fqdn  = "backend.consul-${local.suffix}.${local.domain}"
}

locals {
  selected_zones = slice(data.google_compute_zones.available.names, 0, var.num_zones)
}

locals {
  # Refactored IP lookup logic
  my_ip_cidr = length(data.http.my_ip) > 0 ? "${chomp(data.http.my_ip[0].response_body)}/32" : null

  # Use current IP if no custom networks provided, otherwise use custom networks
  authorized_networks = length(var.additional_authorized_networks) == 0 ? [
    {
      cidr_block   = local.my_ip_cidr
      display_name = "Current IP (auto-detected)"
    }
  ] : var.additional_authorized_networks

  # List of CIDRs for restricting external LoadBalancers
  allowed_cidrs = [for net in local.authorized_networks : net.cidr_block]
}
