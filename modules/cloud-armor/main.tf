resource "google_compute_security_policy" "default" {
  project     = var.project_id
  name        = var.security_policy_name
  description = var.description
  type        = var.type

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.enable_adaptive_protection
      rule_visibility = var.adaptive_protection_rule_visibility
    }
  }
}

resource "google_compute_security_policy_rule" "default" {
  for_each        = { for index, rule in var.rules : index => rule }
  project         = var.project_id
  security_policy = google_compute_security_policy.default.name
  priority        = each.value.priority
  description     = each.value.description
  action          = each.value.action

  match {
    dynamic "expr" {
      for_each = each.value.match.expr != null ? [1] : []
      content {
        expression = each.value.match.expr.expression
      }
    }

    dynamic "config" {
      for_each = (each.value.match.config != null) ? [1] : []
      content {
        src_ip_ranges = try(each.value.match.config.src_ip_ranges, null)
      }
    }
    versioned_expr = try(each.value.match.versioned_expr, null)
  }

  preview = each.value.preview

  dynamic "redirect_options" {
    for_each = each.value.redirect_options != null ? [1] : []
    content {
      type   = each.value.redirect_options.type
      target = each.value.redirect_options.target
    }
  }

  dynamic "rate_limit_options" {
    for_each = each.value.rate_limit_options != null ? [1] : []
    content {
      enforce_on_key = each.value.rate_limit_options.enforce_on_key
      conform_action = each.value.rate_limit_options.conform_action

      dynamic "enforce_on_key_configs" {
        for_each = each.value.rate_limit_options.enforce_on_key_configs != null ? [1] : []
        content {
          enforce_on_key_type = each.value.rate_limit_options.enforce_on_key_configs.enforce_on_key_type
        }
      }

      dynamic "rate_limit_threshold" {
        for_each = each.value.rate_limit_options.rate_limit_threshold != null ? [1] : []
        content {
          count        = each.value.rate_limit_options.rate_limit_threshold.count
          interval_sec = each.value.rate_limit_options.rate_limit_threshold.interval_sec
        }
      }

      exceed_action = each.value.rate_limit_options.exceed_action

      dynamic "ban_threshold" {
        for_each = each.value.rate_limit_options.ban_threshold != null ? [1] : []
        content {
          count        = each.value.rate_limit_options.ban_threshold.count
          interval_sec = each.value.rate_limit_options.ban_threshold.interval_sec
        }
      }

      ban_duration_sec = each.value.rate_limit_options.ban_duration_sec
    }
  }
}
