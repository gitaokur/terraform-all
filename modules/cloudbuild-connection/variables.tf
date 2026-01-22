variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "connections" {
  description = "A list of GitHub connection configurations"
  type = list(object({
    name             = string
    region           = string
    installation_id  = number
    secret_id        = string
    secret_version   = optional(string, "latest")
  }))
}

variable "secret_manager_dependency" {
  description = "Dummy dependency to ensure secret manager runs before connection creation"
  type        = any
  default     = null
}

variable "repositories" {
  type = list(object({
    name            = string
    region          = string
    connection_name = string
    remote_uri      = string
  }))
  default     = []
  description = "List of GitHub repositories to register under the connections"
}

variable "triggers" {
  description = "List of Cloud Build triggers"
  type = list(object({
    name           = string
    description    = optional(string, "")
    region         = string
    filename       = string
    included_files = optional(list(string), [])
    service_account = optional(string)
    github = object({
      owner  = string
      name   = string
      branch = string
    })
  }))
  default = []
}




