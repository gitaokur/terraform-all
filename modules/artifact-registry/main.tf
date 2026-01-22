resource "google_artifact_registry_repository" "repo" {
  for_each = { for repo in var.repositories : repo.name => repo }

  repository_id         = each.value.name
  format                = each.value.format
  location              = each.value.location
  project               = var.project_id

  dynamic "cleanup_policies" {
    for_each = each.value.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action
      condition {
        tag_state             = cleanup_policies.value.condition.tag_state
        tag_prefixes          = cleanup_policies.value.condition.tag_prefixes
        package_name_prefixes = cleanup_policies.value.condition.package_name_prefixes
        older_than            = cleanup_policies.value.condition.older_than
        newer_than            = cleanup_policies.value.condition.newer_than
      }
    }
  }
}
