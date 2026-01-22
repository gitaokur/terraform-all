variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "buckets" {
  description = "List of GCS buckets to create"
  type = list(object({
    name          = string
    storage_class = string # Options: STANDARD, NEARLINE, COLDLINE, ARCHIVE
    location      = string
    lifecycle_rules = optional(list(object({
      age_days = number # Number of days before deleting objects
    })), [])
    versioning_enabled       = optional(bool, false)
    public_access_prevention = optional(string, "enforced")
    cors = optional(object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    }))
    website = optional(object({
      main_page_suffix = string
      not_found_page   = string
    }))
  }))
}
