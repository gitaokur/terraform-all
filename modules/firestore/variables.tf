variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "firestore" {
  type = object({
    name        = string
    location_id = string
    type        = string
    point_in_time_recovery_enablement = optional(string)
    deletion_policy = optional(string) 
  })
  description = "Firestore configuration"
}
