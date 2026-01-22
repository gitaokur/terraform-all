variable "secrets" {
  description = "List of secrets to be created"
  type = list(object({
    name        = string
    secret_file = optional(string) #to get the secrets from a file
    secret_data = optional(string) #to get the secrets from a string
    role        = string
    members     = list(string)
  }))
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}