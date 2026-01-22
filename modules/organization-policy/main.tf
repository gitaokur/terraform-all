resource "google_org_policy_policy" "org_policies" {
  for_each = { for policy in var.policies : policy.constraint => policy }

  name   = "organizations/${var.org_id}/policies/${replace(each.value.constraint, "constraints/", "")}"
  parent = "organizations/${var.org_id}"

  spec {
    dynamic "rules" {
      for_each = length(try(each.value.allowed_values, [])) > 0 ? [each.value] : []
      content {
        values {
          allowed_values = rules.value.allowed_values
        }
      }
    }

    dynamic "rules" {
      for_each = each.value.enforce != null ? [each.value] : []
      content {
        enforce = rules.value.enforce
      }
    }
  }
}
