locals {
  suffix = random_id.suffix.hex
  # Calculate FQDN from prefix and DNS zone (strip trailing dot from GCP dns_name)
  apigw_fqdn = "${var.apigw_prefix}.${trimsuffix(data.google_dns_managed_zone.main.dns_name, ".")}"
}

locals {
  selected_zones = slice(data.google_compute_zones.available.names, 0, var.num_zones)
}

locals {
  # Use current IP if no custom networks provided, otherwise use custom networks
  authorized_networks = length(var.additional_authorized_networks) == 0 ? [
    {
      cidr_block   = "${chomp(data.http.my_ip[0].response_body)}/32"
      display_name = "Current IP (auto-detected)"
    }
  ] : var.additional_authorized_networks
}
