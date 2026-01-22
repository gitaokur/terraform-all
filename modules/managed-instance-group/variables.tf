variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "instance_groups" {
  description = "A map of Managed Instance Group configurations"
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
