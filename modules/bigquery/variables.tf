variable "project_id" {
  description = "Project ID where the dataset will be created"
  type        = string
}

variable "datasets" {
  description = "List of BigQuery dataset definitions"
  type = list(object({
    dataset_id                  = string
    location                    = string
    description                 = optional(string)
    labels                      = optional(map(string))
    default_table_expiration_ms = optional(number)
    delete_contents_on_destroy  = optional(bool)
  }))
}

variable "access" {
  description = "List of access blocks for BigQuery dataset"
  type        = list(object({
    role          = string
    user_by_email = optional(string)
    group_by_email = optional(string)
    domain        = optional(string)
    special_group = optional(string)
    view          = optional(object({
      project_id = string
      dataset_id = string
      table_id   = string
    }))
  }))
  default     = []
}
