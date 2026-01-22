variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "services" {
  description = "A list of Cloud Run services to create"
  type = list(object({
    name                  = string
    region                = string
    image                 = string
    allow_unauthenticated = optional(bool, true)
    cpu                   = optional(number, 1)
    memory                = optional(string, "512Mi")
    concurrency           = optional(number, 80)
    max_instances         = optional(number, 10)
    min_instances         = optional(number, 0) #cold start olmaması istenen bir uygulamada 1 olarak girilmesi tavsiye edilir.
    env_vars              = optional(list(object({
      name  = string
      value = string
    })), )
    env_secret_vars = optional(map(object({
      secret  = string
      version = string
    })), {})
    vpc_connector         = optional(string, null)
    service_account       = optional(string, "")
    iam_bindings          = optional(list(object({ role = string, member = string })))
    ingress               = optional(string, "INGRESS_TRAFFIC_ALL")
    cloud_sql_instances   = optional(list(string), [])
    direct_vpc_egress = optional(object({
      network    = string
      subnetwork = string
    }), null)
    timeout               = optional(string, "300s")
    labels                = optional(map(string), {})
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
variable "min_instances" {
  description = "The minimum number of container instances to keep warm"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "The maximum number of container instances to scale up to"
  type        = number
  default     = 10
}
/* variable "vpc_access_connector_name" {
  type        = string
  description = "The name of the Serverless VPC Access Connector."
  default = ""
}

variable "vpc_access_connector_self_link" {
  type        = string
  description = "The self_link of the Serverless VPC Access Connector."
  default = ""
}

variable "vpc_access_connector_id" {
  type        = string
  description = "The id of the Serverless VPC Access Connector."
  default = ""
} */
variable "traffic" {
  type = list(object({
    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    percent  = optional(number, 100)
    revision = optional(string, null)
    tag      = optional(string, null)
  }))
  description = "Revisionlar arası trafiğin nasıl dağıldığını belirler. Değer girilmediği takdirde son revision %100 trafik alır"
  default     = []
}
variable "template_scaling" {
  type = object({
    min_instance_count = optional(number)
    max_instance_count = optional(number)
  })
  description = "Scaling settings for this Revision."
  default     = null
}
