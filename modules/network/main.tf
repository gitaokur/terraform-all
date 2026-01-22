resource "google_compute_network" "network" {
  provider                                  = google-beta
  project                                   = var.project_id
  name                                      = var.network_name
  auto_create_subnetworks                   = var.auto_create_subnetworks
  routing_mode                              = var.routing_mode
  description                               = var.description
  delete_default_routes_on_create           = var.delete_default_internet_gateway_routes
  mtu                                       = var.mtu
  enable_ula_internal_ipv6                  = var.enable_ipv6_ula
  internal_ipv6_range                       = var.internal_ipv6_range
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
  network_profile                           = var.network_profile
}
resource "google_compute_subnetwork" "subnetwork"{
  provider                                  = google-beta
  project                                   = var.project_id
  network                                   = var.network_name
  for_each                                  = { for subnet in var.subnetworks : subnet.name => subnet } 
  name                                      = each.value.name
  region                                    = each.value.region
  private_ip_google_access                  = each.value.private_ip_google_access
  ip_cidr_range                             = each.value.ip_cidr_range

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  #description                              = var.subnet_description
  depends_on = [google_compute_network.network]

}

# Reserve an IP range for Private Service Access (PSA)
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.network_name}-private-ip-range"
  project       =  var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.self_link
}

# Create a Private Service Access (PSA) connection for Google services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.network.self_link
  service                 = "servicenetworking.googleapis.com"
  deletion_policy = "ABANDON" # for tf destroy to delete the psa connection
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}



resource "google_vpc_access_connector" "connector" { 
  for_each = { for connector in var.connectors : connector.name => connector }
  name          = each.value.name
  region        = each.value.region
  project       = var.project_id 
  subnet {
    name = each.value.subnet_name
  }
  machine_type  = each.value.machine_type
  min_instances = each.value.min_instances
  max_instances = each.value.max_instances
 
  depends_on = [google_compute_subnetwork.subnetwork]
}


# Attach the VPC to the Shared VPC Host Project
resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
  provider = google-beta

  count      = var.shared_vpc_host ? 1 : 0
  project    = var.project_id
  depends_on = [google_compute_network.network]
}

# Allow health checks from Google Cloud ranges
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.network_name}-allow-health-check"
  project = var.project_id
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["allow-health-check"]
}

resource "google_compute_firewall" "custom_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name      = each.value.name
  project   = var.project_id
  network   = google_compute_network.network.name
  direction = each.value.direction
  priority  = each.value.priority

  source_ranges = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null
  target_tags = length(each.value.target_tags) > 0 ? each.value.target_tags : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = length(allow.value.ports) > 0 ? allow.value.ports : null
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = length(deny.value.ports) > 0 ? deny.value.ports : null
    }
  }
}