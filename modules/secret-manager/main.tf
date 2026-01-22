resource "google_secret_manager_secret" "secrets" {
  for_each = { for secret in var.secrets : secret.name => secret }
  
  project                 = var.project_id
  secret_id               = each.value.name
  replication {    
    auto {

    }
  }
}
# Create secret versions
resource "google_secret_manager_secret_version" "secret_versions" {
  for_each = { for secret in var.secrets : secret.name => secret }

  secret                  = google_secret_manager_secret.secrets[each.key].id
  secret_data = (
    contains(keys(each.value), "secret_file") && each.value.secret_file != null
    ? trimspace(file("${path.cwd}/${each.value.secret_file}"))
    : each.value.secret_data
  )
  #secret_data             = each.value.secret_data #file(each.value.secret_file) (file'dan almak için bu gerkebilir)
}

# IAM Binding for Secret Access
resource "google_secret_manager_secret_iam_binding" "secret_iam_binding" {
  for_each = { for secret in var.secrets : secret.name => secret }

  project                  = var.project_id
  secret_id                = google_secret_manager_secret.secrets[each.key].id
  role                     = each.value.role
  members                  = each.value.members
}
