resource "google_pubsub_topic" "topics" {
  project                    = var.project_id
  for_each = { for topic in var.topics : topic.name => topic }
  name                       = each.value.name
  message_retention_duration = each.value.message_retention_duration
  labels                     = each.value.labels
}

resource "google_pubsub_subscription" "subs" {
  project                    = var.project_id
  for_each = { for sub in var.subscriptions : sub.name => sub }

  name  = each.value.name
  topic = google_pubsub_topic.topics[each.value.topic].id

  ack_deadline_seconds = each.value.ack_deadline_seconds
  retain_acked_messages = each.value.retain_acked_messages

  dynamic "push_config" {
    for_each = each.value.push_config != null ? [each.value.push_config] : []
    content {
      push_endpoint = push_config.value.push_endpoint
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_topic != null ? [each.value] : []
    content {
      dead_letter_topic        = google_pubsub_topic.topics[each.value.dead_letter_topic].id
      max_delivery_attempts    = each.value.max_delivery_attempts
    }
  }
}
