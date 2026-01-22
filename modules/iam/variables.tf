variable "iam_groups" {
  description = "List of IAM groups with roles and members"
  type = list(object({
    name              = string
    roles             = list(string)
    members           = list(string)
  }))
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
