variable "project_id" {
  description = "The GCP project where roles are applied"
  type        = string
}

variable "bindings" {
  description = "List of role bindings for each member"
  type = list(object({
    member = string
    role   = list(string)
  }))
}
