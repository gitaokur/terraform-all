variable "project_id" {
  description         = "GCP Project ID"
  type                = string
}

variable "repositories" {
  description = "List of Artifact Registry repositories to create"
  type = list(object({
    name            = string
    format          = string
    location        = string
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
}
