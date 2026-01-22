resource "google_monitoring_alert_policy" "alerts" {
  for_each = { for policy in var.alert_policies : policy.display_name => policy }

  project = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner

  dynamic "conditions" {
    for_each = each.value.condition.condition_type == "threshold" ? [1] : []
    content {
      condition_threshold {
        filter          = each.value.condition.filter
        duration        = each.value.condition.duration
        comparison      = each.value.condition.comparison
        threshold_value = each.value.condition.threshold_value
        dynamic "aggregations" {
            for_each = try(each.value.condition.aggregations, [])
            content {
                alignment_period   = aggregations.value.alignment_period
                per_series_aligner = aggregations.value.per_series_aligner
    }
}
      }
      display_name = each.value.condition.display_name
    }
  }

  dynamic "conditions" {
    for_each = each.value.condition.condition_type == "absent" ? [1] : []
    content {
      condition_absent {
        filter   = each.value.condition.filter
        duration = each.value.condition.duration
        dynamic "aggregations" {
            for_each = try(each.value.condition.aggregations, [])
            content {
                alignment_period   = aggregations.value.alignment_period
                per_series_aligner = aggregations.value.per_series_aligner
    }
}
      }
      display_name = each.value.condition.display_name
    }
  }
  notification_channels = [
    for idx in lookup(each.value, "notification_channels", []) :
    google_monitoring_notification_channel.channels[idx].name
  ]
   /*  documentation {
    content = each.value.documentation
  }  */
   dynamic "documentation" {
  for_each = try([each.value.documentation], []) # Only creates the block if defined
  content {
    content = try(documentation.value.content, "No documentation provided.")
    subject = try(documentation.value.subject, "Monitoring Alert")
  }
} 


  user_labels = each.value.user_labels
  enabled     = each.value.enabled
}

resource "google_monitoring_notification_channel" "channels" {
  for_each = { for idx, channel in var.notification_channels : idx => channel }

  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
}

resource "google_monitoring_uptime_check_config" "uptime_checks" {
  for_each = { for idx, check in var.uptime_checks : idx => check }

  project      = var.project_id
  display_name = each.value.display_name
  timeout      = each.value.timeout
  period       = each.value.period

  dynamic "monitored_resource" {
  for_each = lookup(each.value, "monitored_resource", null) != null ? [each.value.monitored_resource] : []
  content {
    type   = monitored_resource.value.type
    labels = monitored_resource.value.labels
  }
}

  dynamic "http_check" {
  for_each = lookup(each.value, "http_check", null) != null ? [each.value.http_check] : []
  content {
    use_ssl        = lookup(http_check.value, "use_ssl", null)
    path           = lookup(http_check.value, "path", null)
    port           = lookup(http_check.value, "port", null)
    request_method = lookup(http_check.value, "request_method", null)
    mask_headers   = lookup(http_check.value, "mask_headers", false)
    validate_ssl   = lookup(http_check.value, "validate_ssl", true)
    headers        = lookup(http_check.value, "headers", {})
  }
  }

  dynamic "content_matchers" {
    for_each = lookup(each.value.http_check, "content_matchers", [])
    content {
      content = content_matchers.value.content
      matcher = lookup(content_matchers.value, "matcher", null)
    }
  }

}