resource "google_bigquery_dataset" "this" {
  for_each                    = { for d in var.datasets : d.dataset_id => d }
  project                     = var.project_id
  dataset_id                  = each.value.dataset_id
  location                    = each.value.location
  description                 = lookup(each.value, "description", null)
  default_table_expiration_ms = lookup(each.value, "default_table_expiration_ms", null)
  delete_contents_on_destroy  = lookup(each.value, "delete_contents_on_destroy", false)
  labels                      = lookup(each.value, "labels", null)

   dynamic "access" {
    for_each = lookup(each.value, "access", [])
    content {
      role   = access.value.role
      user_by_email = lookup(access.value, "user_by_email", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      domain = lookup(access.value, "domain", null)

      dynamic "view" {
        for_each = access.value.view != null ? [access.value.view] : []
        content {
          project_id = view.value.project_id
          dataset_id = view.value.dataset_id
          table_id   = view.value.table_id
        }
      }
    }
  }
}
