resource "google_storage_bucket" "buckets" {
  for_each      = { for bucket in var.buckets : bucket.name => bucket }
  name          = each.value.name
  project       = var.project_id
  location      = each.value.location
  storage_class = each.value.storage_class
  public_access_prevention = each.value.public_access_prevention

  versioning {
    enabled = each.value.versioning_enabled
  }

  dynamic "cors" {
    for_each = each.value.cors != null ? [1] : []
    content {
      origin          = each.value.cors.origin
      method          = each.value.cors.method
      response_header = each.value.cors.response_header
      max_age_seconds = each.value.cors.max_age_seconds
    }
  }

  dynamic "website" {
    for_each = each.value.website != null ? [1] : []
    content {
      main_page_suffix = each.value.website.main_page_suffix
      not_found_page   = each.value.website.not_found_page
    }
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules
    content {
      condition {
        age = lifecycle_rule.value.age_days
      }
      action {
        type = "Delete"
      }
    }
  }
}
