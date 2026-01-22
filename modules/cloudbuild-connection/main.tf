resource "google_cloudbuildv2_connection" "github_connection" {
  for_each = { for conn in var.connections : conn.name => conn }

  name     = each.value.name
  project  = var.project_id
  location = each.value.region

  github_config {
    app_installation_id = each.value.installation_id

    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/${each.value.secret_id}/versions/${each.value.secret_version}"
    }
  }

  depends_on = [var.secret_manager_dependency]
}

resource "google_cloudbuildv2_repository" "repos" {
  for_each = { for repo in var.repositories : repo.name => repo }

  project           = var.project_id
  location          = each.value.region
  name              = each.value.name
  remote_uri        = each.value.remote_uri
  parent_connection = "projects/${var.project_id}/locations/${each.value.region}/connections/${each.value.connection_name}"

  depends_on = [google_cloudbuildv2_connection.github_connection]
}

resource "google_cloudbuild_trigger" "triggers" {
  for_each = { for t in var.triggers : t.name => t }

  name        = each.value.name
  description = each.value.description
  filename    = each.value.filename
  project     = var.project_id
  location    = each.value.region


  included_files = try(each.value.included_files, [])

  github {
    owner = each.value.github.owner
    name  = each.value.github.name

    push {
      branch = each.value.github.branch
    }
  }

  service_account = try(each.value.service_account, null)
  
  depends_on = [google_cloudbuildv2_repository.repos]
}




