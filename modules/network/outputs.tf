output "network" {
  value       = google_compute_network.network
  description = "The VPC resource being created"
}

output "network_name" {
  value       = google_compute_network.network.name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = google_compute_network.network.id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = google_compute_network.network.self_link
  description = "The URI of the VPC being created"
}

output "vpc_access_connectors" {
  value = { for key, connector in google_vpc_access_connector.connector : key => connector.name }
  description = "A map of VPC Access Connector names, keyed by connector name"
}

output "vpc_access_connectors_self_link" {
  value = { for key, connector in google_vpc_access_connector.connector : key => connector.self_link }
  description = "A map of VPC Access Connector self_links, keyed by connector name"
}

output "vpc_access_connectors_id" {
  value = { for key, connector in google_vpc_access_connector.connector : key => connector.id }
  description = "A map of VPC Access Connector ids, keyed by connector name"
}

output "private_ip_alloc_name" {
  description = "Reserved Private IP range for Private Service Access"
  value       = google_compute_global_address.private_ip_alloc.name
}

output "private_vpc_connection_id" {
  description = "The ID of the Private VPC Connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "subnetworks_self_links" {
  description = "A map of subnetwork self_links"
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.self_link }
}
