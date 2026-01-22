variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "enable_public_ip" {
  description = "Enable or disable public IP for Cloud SQL"
  type        = bool
  default     = false # Default to private instance (no public IP)
}

variable "vpc_self_link" {
  description = "The self-link of the VPC where Cloud SQL should be deployed"
  type        = string
}
variable "maintenance_day" {
  description = "Day of the week for maintenance (1=Monday, 7=Sunday)"
  type        = number
  default     = 7 # Default to Sunday
}

variable "maintenance_hour" {
  description = "Hour of the day for maintenance (UTC time, 0-23)"
  type        = number
  default     = 3 # Default to 3 AM UTC
}

variable "update_track" {
  description = "Update track for maintenance (canary or stable)"
  type        = string
  default     = "stable"
}

variable "database" {
  description = "List of GCS buckets to create"
  type = map(object({
    database_version = string
    instance_name    = string
    database_name    = string
    db_user          = optional(string)
    db_password      = optional(string) # secret_name = string
    region           = string
    tier             = string
    private_network  = string # maybe shsould be optional
    authorized_networks = optional(list(object({
      name  = string
      value = string
    })), [])
    backup_enabled      = optional(bool, true)
    binary_log_enabled  = optional(bool, false)
    disk_size           = optional(number, 50)
    deletion_protection = optional(bool, true)
    availability_type   = optional(string, "ZONAL") # ZONAL or REGIONAL
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
