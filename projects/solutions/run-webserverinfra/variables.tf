variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# --- NETWORK MODULE ---
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
}

variable "shared_vpc_host" {
  type    = bool
  default = false
}

variable "psa_prefix_length" {
  type    = number
  default = 16
}

variable "network_description" {
  type    = string
  default = ""
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "delete_default_internet_gateway_routes" {
  type    = bool
  default = false
}

variable "mtu" {
  type    = number
  default = 1460
}

variable "enable_ipv6_ula" {
  type    = bool
  default = false
}

variable "internal_ipv6_range" {
  type    = string
  default = null
}

variable "network_firewall_policy_enforcement_order" {
  type    = string
  default = null
}

variable "network_profile" {
  type    = string
  default = null
}

variable "subnetworks" {
  description = "List of subnetworks"
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
  description = "List of VPC access connectors"
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

variable "firewall_rules" {
  description = "List of firewall rules"
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

# --- ARTIFACT REGISTRY MODULE ---
variable "artifact_repositories" {
  description = "List of Artifact Registry repositories"
  type = list(object({
    name     = string
    format   = string
    location = string
    cleanup_policies = optional(list(object({
      id     = string
      action = string
      condition = object({
        tag_state             = optional(string)
        tag_prefixes          = optional(list(string))
        package_name_prefixes = optional(list(string))
        older_than            = optional(string)
        newer_than            = optional(string)
      })
    })), [])
  }))
  default = []
}

# --- CLOUDBUILD CONNECTION MODULE ---
variable "cloudbuild_connections" {
  description = "GitHub connection configurations"
  type = list(object({
    name            = string
    region          = string
    installation_id = number
    secret_id       = string
    secret_version  = optional(string, "latest")
  }))
  default = []
}

variable "cloudbuild_repositories" {
  description = "GitHub repositories for Cloud Build"
  type = list(object({
    name            = string
    region          = string
    connection_name = string
    remote_uri      = string
  }))
  default = []
}

variable "cloudbuild_triggers" {
  description = "Cloud Build triggers"
  type = list(object({
    name            = string
    description     = optional(string, "")
    region          = string
    filename        = string
    included_files  = optional(list(string), [])
    service_account = optional(string)
    github = object({
      owner  = string
      name   = string
      branch = string
    })
  }))
  default = []
}

# --- CLOUD Armor MODULE ---
variable "armor_security_policy_name" {
  type    = string
  default = "website-security-policy"
}

variable "armor_rules" {
  description = "Cloud Armor rules"
  type = list(object({
    priority    = number
    description = string
    action      = string
    match = object({
      versioned_expr = optional(string)
      expr = optional(object({
        expression = string
      }), null)
      config = optional(object({
        src_ip_ranges = optional(list(string))
      }))
    })
    preview = bool
  }))
  default = []
}

# --- CLOUD RUN MODULE ---
variable "run_services" {
  description = "List of Cloud Run services"
  type = list(object({
    name                  = string
    region                = string
    image                 = string
    allow_unauthenticated = optional(bool, true)
    cpu                   = optional(number, 1)
    memory                = optional(string, "512Mi")
    concurrency           = optional(number, 80)
    max_instances         = optional(number, 10)
    min_instances         = optional(number, 0)
    env_vars = optional(list(object({
      name  = string
      value = string
    })), [])
    vpc_connector       = optional(string, null)
    service_account     = optional(string, "")
    ingress             = optional(string, "INGRESS_TRAFFIC_ALL")
    cloud_sql_instances = optional(list(string), [])
    direct_vpc_egress = optional(object({
      network    = string
      subnetwork = string
    }), null)
    timeout = optional(string, "300s")
    labels  = optional(map(string), {})
    startup_probe = optional(object({
      timeout_seconds   = number
      period_seconds    = number
      failure_threshold = number
      tcp_socket = optional(object({
        port = number
      }))
      http_get = optional(object({
        path = string
        port = number
      }))
    }))
    liveness_probe = optional(object({
      timeout_seconds   = number
      period_seconds    = number
      failure_threshold = number
      http_get = optional(object({
        path = string
        port = number
      }))
    }))
  }))
}

# --- CLOUD SQL MODULE ---
variable "sql_enable_public_ip" {
  type    = bool
  default = false
}

variable "sql_maintenance_day" {
  type    = number
  default = 7
}

variable "sql_maintenance_hour" {
  type    = number
  default = 3
}

variable "sql_update_track" {
  type    = string
  default = "stable"
}

variable "database" {
  description = "Database instances"
  type = map(object({
    database_version    = string
    instance_name       = string
    database_name       = string
    region              = string
    tier                = string
    private_network     = string
    db_user             = optional(string, "admin")
    db_password         = optional(string, null)
    deletion_protection = optional(bool, true)
    availability_type   = optional(string, "ZONAL")
    database_flags = optional(list(object({
      name  = string
      value = string
    })), [])
    insights_config = optional(object({
      query_insights_enabled  = optional(bool, true)
      query_string_length     = optional(number, 1024)
      record_application_tags = optional(bool, true)
      record_client_address   = optional(bool, false)
    }), {})
  }))
}

# --- CLOUD STORAGE MODULE ---
variable "buckets" {
  description = "Cloud Storage buckets"
  type = list(object({
    name          = string
    storage_class = string
    location      = string
    lifecycle_rules = optional(list(object({
      age_days = number
    })), [])
    versioning_enabled       = optional(bool, false)
    public_access_prevention = optional(string, "enforced")
    cors = optional(object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    }))
    website = optional(object({
      main_page_suffix = string
      not_found_page   = string
    }))
  }))
}

# --- LOAD BALANCER MODULE ---
variable "lb_name" {
  type = string
}

variable "https_redirect" {
  type    = bool
  default = true
}

variable "ssl" {
  type    = bool
  default = true
}

variable "create_ssl_certificate" {
  type    = bool
  default = false
}

variable "ssl_certificates" {
  type    = list(string)
  default = []
}

variable "managed_ssl_certificate_domains" {
  type    = list(string)
  default = []
}
