variable "project_id" {
  description = "The ID of the project where App Engine will be created."
  type        = string
}

variable "location_id" {
  description = "The location (region) of the App Engine application."
  type        = string
}

variable "services" {
  description = "List of App Engine services to deploy."
  type = list(object({
    service_id     = string
    runtime        = string
    source_url     = optional(string)
    entrypoint     = optional(string)
    instance_class = optional(string, "F1")
    service_account = optional(string)
    env_variables  = optional(map(string), {})
    automatic_scaling = optional(object({
      max_concurrent_requests       = optional(number)
      max_idle_instances            = optional(number)
      min_idle_instances            = optional(number)
      target_cpu_utilization        = optional(number)
      target_throughput_utilization = optional(number)
      min_instances                 = optional(number)
      max_instances                 = optional(number)
    }))
    basic_scaling = optional(object({
      max_instances = number
      idle_timeout  = optional(string)
    }))
    manual_scaling = optional(object({
      instances = number
    }))
  }))
  default = []
}
