module "network" {
  source       = "../../../modules/network"
  project_id   = var.project_id
  network_name = var.network_name
  
  routing_mode                              = var.routing_mode
  shared_vpc_host                           = var.shared_vpc_host
  psa_prefix_length                         = var.psa_prefix_length
  description                               = var.network_description
  auto_create_subnetworks                   = var.auto_create_subnetworks
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  mtu                                       = var.mtu
  enable_ipv6_ula                           = var.enable_ipv6_ula
  internal_ipv6_range                       = var.internal_ipv6_range
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
  network_profile                           = var.network_profile
  subnetworks                               = var.subnetworks
  connectors                                = var.connectors
  firewall_rules                            = var.firewall_rules
}

module "managed_instance_group" {
  source          = "../../../modules/managed-instance-group"
  project_id      = var.project_id
  instance_groups = {
    for k, v in var.instance_groups : k => {
      region                  = v.region
      machine_type            = v.machine_type
      source_image            = v.source_image
      network                 = module.network.network_self_link
      subnetwork              = module.network.subnetworks_self_links[v.subnetwork]
      target_size             = v.target_size
      tags                    = concat(v.tags, ["allow-health-check"])
      labels                  = v.labels
      metadata_startup_script = v.metadata_startup_script
      service_account         = v.service_account
      assign_external_ip      = v.assign_external_ip
    }
  }
}

module "load_balancer" {
  source     = "../../../modules/load-balancer"
  project_id = var.project_id
  lb_name    = var.lb_name
  
  https_redirect                  = var.https_redirect
  ssl                             = var.ssl
  create_ssl_certificate          = var.create_ssl_certificate
  private_key                     = var.private_key
  certificate                     = var.certificate
  ssl_certificates                = var.ssl_certificates
  ssl_policy                      = var.ssl_policy
  managed_ssl_certificate_domains = var.managed_ssl_certificate_domains
  random_certificate_suffix       = var.random_certificate_suffix
  security_policy                 = var.security_policy
  iap_config                      = var.iap_config

  backends   = {
    default = {
      protocol = "HTTP"
      groups   = [
        for k, v in module.managed_instance_group.instance_groups : {
          group = v
        }
      ]
    }
  }
}

module "cloud_sql" {
  source           = "../../../modules/cloud-sql"
  project_id       = var.project_id
  vpc_self_link    = module.network.network_self_link
  
  enable_public_ip = var.sql_enable_public_ip
  maintenance_day  = var.sql_maintenance_day
  maintenance_hour = var.sql_maintenance_hour
  update_track     = var.sql_update_track
  database         = var.database

  depends_on = [module.network.private_vpc_connection_id]
}

module "cloud_storage" {
  source     = "../../../modules/cloud-storage"
  project_id = var.project_id
  buckets    = var.buckets
}
