# General Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Network Module Variables
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
}

variable "shared_vpc_host" {
  type        = bool
  description = "Makes this project a Shared VPC host if 'true' (default 'false')"
  default     = false
}

variable "psa_prefix_length" {
  description = "Prefix length for Private Service Access IP range"
  type        = number
  default     = 16
}

variable "network_description" {
  type        = string
  description = "An optional description of this resource."
  default     = ""
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode'"
  default     = false
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' are deleted"
  default     = false
}

variable "mtu" {
  type        = number
  description = "The network MTU"
  default     = 1460
}

variable "enable_ipv6_ula" {
  type        = bool
  description = "Enabled IPv6 ULA"
  default     = false
}

variable "internal_ipv6_range" {
  type        = string
  default     = null
  description = "When enabling IPv6 ULA, optionally, specify a /48 from fd20::/20"
}

variable "network_firewall_policy_enforcement_order" {
  type        = string
  default     = null
  description = "Set the order that Firewall Rules and Firewall Policies are evaluated."
}

variable "network_profile" {
  type        = string
  default     = null
  description = "A full or partial URL of the network profile"
}

variable "subnetworks" {
  description = "A list of subnetworks to create"
  type = list(object({
    name                     = string
    region                   = string
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, false)
    secondary_ip_ranges      = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}

variable "connectors" {
  description = "A list of VPC access connector to create"
  type = list(object({
    name          = string
    region        = string
    subnet_name   = string
    machine_type  = string
    min_instances = number
    max_instances = number
  }))
  default = []
}

# Managed Instance Group Variables
variable "instance_groups" {
  description = "Configurations for Managed Instance Groups"
  type = map(object({
    region                  = string
    machine_type            = optional(string, "e2-medium")
    source_image            = optional(string, "projects/debian-cloud/global/images/family/debian-11")
    network                 = string
    subnetwork              = string
    target_size             = optional(number, 1)
    tags                    = optional(list(string), [])
    labels                  = optional(map(string), {})
    metadata_startup_script = optional(string, "")
    service_account         = optional(string, "")
    assign_external_ip      = optional(bool, false)
  }))
}

# Load Balancer Variables
variable "lb_name" {
  description = "The name of the Load Balancer"
  type        = string
}

variable "https_redirect" {
  description = "Set to `true` to enable https redirect on the lb."
  type        = bool
  default     = true
}

variable "ssl" {
  description = "Set to `true` to enable SSL support."
  type        = bool
  default     = true
}

variable "create_ssl_certificate" {
  description = "If `true`, Create certificate using `private_key/certificate`"
  type        = bool
  default     = false
}

variable "private_key" {
  description = "Content of the private SSL key."
  type        = string
  default     = null
}

variable "certificate" {
  description = "Content of the SSL certificate."
  type        = string
  default     = null
}

variable "ssl_certificates" {
  description = "SSL cert self_link list."
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  type        = string
  description = "Selfink to SSL Policy"
  default     = null
}

variable "managed_ssl_certificate_domains" {
  description = "Create Google-managed SSL certificates for specified domains."
  type        = list(string)
  default     = []
}

variable "random_certificate_suffix" {
  description = "Bool to enable/disable random certificate name generation."
  type        = bool
  default     = false
}

variable "security_policy" {
  description = "The resource URL for the security policy"
  type        = string
  default     = null
}

variable "iap_config" {
  description = "Settings for enabling Cloud Identity Aware Proxy Structure."
  type = object({
    enabled              = optional(bool)
    oauth2_client_id     = optional(string)
    oauth2_client_secret = optional(string)
  })
  default = { enabled = false }
}

# Cloud SQL Variables
variable "sql_enable_public_ip" {
  description = "Enable or disable public IP for Cloud SQL"
  type        = bool
  default     = false
}

variable "sql_maintenance_day" {
  description = "Day of the week for maintenance (1=Monday, 7=Sunday)"
  type        = number
  default     = 7
}

variable "sql_maintenance_hour" {
  description = "Hour of the day for maintenance (UTC time, 0-23)"
  type        = number
  default     = 3
}

variable "sql_update_track" {
  description = "Update track for maintenance (canary or stable)"
  type        = string
  default     = "stable"
}

variable "database" {
  description = "Cloud SQL database configurations"
  type = map(object({
    database_version = string
    instance_name    = string
    database_name    = string
    db_user          = optional(string)
    db_password      = optional(string)
    region           = string
    tier             = string
    private_network  = string
    authorized_networks = optional(list(object({
      name  = string
      value = string
    })), [])
    backup_enabled      = optional(bool, true)
    binary_log_enabled  = optional(bool, false)
    disk_size           = optional(number, 50)
    deletion_protection = optional(bool, true)
  }))
}

# Cloud Storage Variables
variable "buckets" {
  description = "A list of objects, each describing a bucket"
  type = list(object({
    name          = string
    storage_class = string
    location      = string
    lifecycle_rules = optional(list(object({
      age_days = number
    })), [])
  }))
}

variable "firewall_rules" {
  description = "A list of firewall rules to create"
  type = list(object({
    name        = string
    direction   = optional(string, "INGRESS")
    priority    = optional(number, 1000)
    ranges      = list(string)
    target_tags = optional(list(string), [])
    allow       = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
    deny        = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}
