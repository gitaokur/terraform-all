variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_accounts" {
  description = "List of service accounts with roles"
  type        = list(object({
    name         = string
    display_name = optional(string, "")
    description  = optional(string, "")
    roles        = list(string)
  }))
}
