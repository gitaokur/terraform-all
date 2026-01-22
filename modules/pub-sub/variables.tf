variable "project_id" {
  description = "Project ID where the dataset will be created"
  type        = string
}

variable "topics" {
  description = "List of topics with optional retention and labels"
  type = list(object({
    name                       = string
    message_retention_duration = optional(string)
    labels                     = optional(map(string))
  }))
}

variable "subscriptions" {
  description = "List of subscriptions"
  type = list(object({
    name                   = string
    topic                  = string
    ack_deadline_seconds  = number
    retain_acked_messages = bool
    push_config = optional(object({
      push_endpoint = string
    }))
    dead_letter_topic     = optional(string)
    max_delivery_attempts = optional(number)
  }))
}
