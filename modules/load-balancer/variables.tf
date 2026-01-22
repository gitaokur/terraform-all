variable "project_id" {
  description = "The project ID where the load balancer will be created"
  type        = string
}

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
  description = "Set to `true` to enable SSL support. If `true` then at least one of these are required: 1) `ssl_certificates` OR 2) `create_ssl_certificate` set to `true` and `private_key/certificate` OR  3) `managed_ssl_certificate_domains`, OR 4) `certificate_map`"
  type        = bool
  default     = true
}

variable "create_ssl_certificate" {
  description = "If `true`, Create certificate using `private_key/certificate`"
  type        = bool
  default     = false
}

variable "private_key" {
  description = "Content of the private SSL key. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true`"
  type        = string
  default     = null
}

variable "certificate" {
  description = "Content of the SSL certificate. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true`"
  type        = string
  default     = null
}

variable "ssl_certificates" {
  description = "SSL cert self_link list. Requires `ssl` to be set to `true`"
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  type        = string
  description = "Selfink to SSL Policy"
  default     = null
}

variable "managed_ssl_certificate_domains" {
  description = "Create Google-managed SSL certificates for specified domains. Requires `ssl` to be set to `true`"
  type        = list(string)
  default     = []
}

variable "random_certificate_suffix" {
  description = "Bool to enable/disable random certificate name generation. Set and keep this to true if you need to change the SSL cert."
  type        = bool
  default     = false
}

variable "security_policy" {
  description = "The resource URL for the security policy to associate with the backend service"
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
 
variable "backends" {
  description = "Map backend indices to list of backend maps."
  validation {
    condition = alltrue([
      for backend_key, backend_value in var.backends :
      alltrue([
        for neg_backend in backend_value.serverless_neg_backends :
        contains(["cloud-run", "cloud-function", "app-engine"], neg_backend.type)
      ])
    ])
    error_message = "serverless_neg_backend type should be either 'cloud-run' or 'cloud-function' or 'app-engine'."
  }
  type = map(object({
    project                 = optional(string)
    protocol                = optional(string)
    port_name               = optional(string)
    description             = optional(string)
    enable_cdn              = optional(bool)
    compression_mode        = optional(string)
    security_policy         = optional(string, null)
    edge_security_policy    = optional(string, null)
    custom_request_headers  = optional(list(string))
    custom_response_headers = optional(list(string))

    connection_draining_timeout_sec = optional(number)
    session_affinity                = optional(string)
    affinity_cookie_ttl_sec         = optional(number)
    locality_lb_policy              = optional(string)

     log_config = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
    }), { enable = true, sample_rate = 1.0 })


    groups = optional(list(object({
      group                        = string
      balancing_mode               = optional(string, "UTILIZATION")
      capacity_scaler              = optional(number, 1.0)
      description                  = optional(string)
      max_utilization              = optional(number, 0.8)
      max_rate                     = optional(number)
      max_rate_per_instance        = optional(number)
      max_connections              = optional(number)
      max_connections_per_instance = optional(number)
      max_connections_per_endpoint = optional(number)
    })), [])


    serverless_neg_backends = optional(list(object({
      region  = string,
      type    = string, // cloud-run, cloud-function and app-engine
      service = object({ name : string, version : optional(string) })
    })), [])
  }))
}

