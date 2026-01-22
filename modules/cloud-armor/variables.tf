variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "security_policy_name" {
  description = "Name of the global security policy"
  type        = string
}

variable "description" {
  description = "Description of the global security policy"
  type        = string
  default     = "Managed by Terraform"
}

variable "type" {
  description = "The type indicates the intended use of the security policy. For CLOUD_ARMOR policies, this field must be specified as CLOUD_ARMOR."
  type        = string
  default     = "CLOUD_ARMOR"
}

variable "rules" {
  description = "List of rules for the security policy"
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
        layer4_configs = optional(list(object({
          ip_protocol = string
          ports = list(string)
        })))
      }))
    })
    preview = bool
    redirect_options = optional(object({
      type = string
      target = optional(string)
    }))
    rate_limit_options = optional(object({
      enforce_on_key = string
      enforce_on_key_configs = optional(object({
        enforce_on_key_type = string
      }))
      rate_limit_threshold = optional(object({
        count = number
        interval_sec = number
      }))
      conform_action = optional(string, "allow")
      exceed_action = string
      ban_threshold = optional(object({
        count = number
        interval_sec = number
      }))
      ban_duration_sec = optional(number)
    }))
    adaptive_protection_config = optional(object({
      auto_deploy_config = object({
        confidence_threshold = number
        expiration_sec = number
      })
    }))
  }))
  default = []
}
variable "enable_adaptive_protection" {
  description = "Enable Adaptive Protection for Cloud Armor (Layer 7 DDoS Defense)."
  type        = bool
  default     = true
}

variable "adaptive_protection_rule_visibility" {
  description = "Determines if adaptive protection rules are visible to users. Can be STANDARD or PREMIUM."
  type        = string
  default     = "STANDARD"
}
