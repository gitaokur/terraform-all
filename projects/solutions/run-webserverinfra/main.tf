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

module "artifact_registry" {
  source       = "../../../modules/artifact-registry"
  project_id   = var.project_id
  repositories = [
    for repo in var.artifact_repositories : merge(repo, {
      cleanup_policies = repo.cleanup_policies
    })
  ]
}

module "cloudbuild_connection" {
  source                    = "../../../modules/cloudbuild-connection"
  project_id                = var.project_id
  connections               = var.cloudbuild_connections
  repositories              = var.cloudbuild_repositories
  triggers                  = var.cloudbuild_triggers
  secret_manager_dependency = [] # Optional, adjust if secret manager is used
}

module "cloud_armor" {
  source               = "../../../modules/cloud-armor"
  project_id           = var.project_id
  security_policy_name = var.armor_security_policy_name
  rules                = var.armor_rules
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

module "cloud_run" {
  source     = "../../../modules/cloud-run"
  project_id = var.project_id
  services   = [
    for svc in var.run_services : merge(svc, {
      vpc_connector       = svc.direct_vpc_egress != null ? null : (svc.vpc_connector != null ? svc.vpc_connector : (length(module.network.vpc_access_connectors_id) > 0 ? module.network.vpc_access_connectors_id[0] : null))
      cloud_sql_instances = length(svc.cloud_sql_instances) > 0 ? svc.cloud_sql_instances : [for k, v in module.cloud_sql.database_instances : v.connection_name]
      direct_vpc_egress   = svc.direct_vpc_egress != null ? svc.direct_vpc_egress : {
        network    = var.network_name
        subnetwork = var.subnetworks[0].name
      }
      timeout        = svc.timeout
      labels         = svc.labels
      startup_probe  = svc.startup_probe
      liveness_probe = svc.liveness_probe
    })
  ]
}

module "load_balancer" {
  source     = "../../../modules/load-balancer"
  project_id = var.project_id
  lb_name    = var.lb_name
  
  https_redirect                  = var.https_redirect
  ssl                             = var.ssl
  create_ssl_certificate          = var.create_ssl_certificate
  ssl_certificates                = var.ssl_certificates
  managed_ssl_certificate_domains = var.managed_ssl_certificate_domains
  security_policy                 = module.cloud_armor.security_policy_id

  backends = {
    default = {
      protocol = "HTTP"
      serverless_neg_backends = [
        for svc in var.run_services : {
          type   = "cloud-run"
          region = svc.region
          service = {
            name = svc.name
          }
        }
      ]
    }
  }
}

module "cloud_storage" {
  source     = "../../../modules/cloud-storage"
  project_id = var.project_id
  buckets    = var.buckets
}
