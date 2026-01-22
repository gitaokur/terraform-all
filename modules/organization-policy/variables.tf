variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "policies" {
  description = "List of organization policies"
  type        = list(object({
    constraint     = string
    enforce        = optional(bool)
    allowed_values = optional(list(string), [])
  }))
}