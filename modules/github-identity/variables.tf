variable "project_id" {
  type = string
}

variable "identity_pools" {
  description = "List of workload identity pools with providers and IAM role mappings"
  type = list(object({
    pool_id               = string
    pool_display_name     = optional(string, "GitHub Actions Pool")
    provider_id           = optional(string, "github")
    provider_display_name = optional(string, "GitHub")
    location              = string
    github_org            = string
    github_repo_name      = string
    service_account_email = string
    repo_roles            = list(string)
    sa_roles              = list(string)
  }))

  validation {
    condition     = alltrue([for pool in var.identity_pools : pool.location == "global"])
    error_message = "Workload Identity Federation only supports 'global' as location — it must be explicitly set to 'global'."
  }
}
