variable "project_id"{
    type        = string
    description = "GCP project ID"
}

variable "notification_channels" {
  type  = list(object({
    display_name = string
    type         = string
    labels       = map(string)
  }))
  default        = []
  description    = "List of notification channels (email, SMS, etc.)"
}

variable "alert_policies" {
  description = "List of alerting policies"
  type = list(object({
    display_name          = string
    combiner              = string
    enabled               = optional(bool, true)
    user_labels           = optional(map(string), {})
    documentation = optional(object({
        content = string
        subject = optional(string)
}))
    notification_channels = optional(list(string), [])

    condition = object({
      display_name    = string
      filter          = string
      duration        = string
      condition_type  = string # "threshold" or "absent"
      comparison      = optional(string)
      threshold_value = optional(number)
      aggregations = list(object({
        alignment_period   = string
        per_series_aligner = string
      }))
    })
  }))
}
variable "uptime_checks" {
  description = "Map of uptime check configurations."
  type = list(object({
    display_name = string
    timeout      = string
    period       = string

    monitored_resource = optional(object({
      type   = string
      labels = map(string)
    }))

    http_check = optional(object({
      use_ssl        = optional(bool)
      path           = optional(string)
      port           = optional(number)
      request_method = optional(string)
      mask_headers   = optional(bool)
      validate_ssl   = optional(bool)
      headers        = optional(map(string))
    }))

    content_matchers = optional(list(object({
      content = string
    })))
  }))
}
