data "google_project" "project" {
  project_id = var.project_id
}

resource "google_iam_workload_identity_pool" "pools" {
  for_each = { for pool in var.identity_pools : pool.pool_id => pool }

  project                   = var.project_id
  workload_identity_pool_id = each.value.pool_id
  display_name              = each.value.pool_display_name
}

resource "google_iam_workload_identity_pool_provider" "providers" {
  for_each = { for pool in var.identity_pools : pool.pool_id => pool }

  project       = var.project_id
  workload_identity_pool_id = each.value.pool_id
  workload_identity_pool_provider_id = each.value.provider_id
  display_name  = each.value.provider_display_name

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == \"${each.value.github_org}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.pools]
}

locals {
  repo_bindings_expanded = flatten([
    for pool in var.identity_pools : [
      for role in pool.repo_roles : {
        pool_id  = pool.pool_id
        location = pool.location
        repo     = pool.github_repo_name
        role     = role
      }
    ]
  ])

  sa_bindings_expanded = flatten([
    for pool in var.identity_pools : [
      for role in pool.sa_roles : {
        pool_id         = pool.pool_id
        location        = pool.location
        repo            = pool.github_repo_name
        role            = role
        service_account = pool.service_account_email
      }
    ]
  ])
}

resource "google_project_iam_member" "repo_bindings_multi" {
  for_each = {
    for entry in local.repo_bindings_expanded :
    "${entry.pool_id}-${entry.role}" => entry
  }

  project = var.project_id
  role    = each.value.role
  member  = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/${each.value.location}/workloadIdentityPools/${each.value.pool_id}/attribute.repository/${each.value.repo}"

  depends_on = [
    google_iam_workload_identity_pool.pools,
    google_iam_workload_identity_pool_provider.providers
  ]
}

resource "google_service_account_iam_member" "sa_bindings_multi" {
  for_each = {
    for entry in local.sa_bindings_expanded :
    "${entry.pool_id}-${entry.role}" => entry
  }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.service_account}"
  role               = each.value.role
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/${each.value.location}/workloadIdentityPools/${each.value.pool_id}/attribute.repository/${each.value.repo}"

  depends_on = [
    google_iam_workload_identity_pool.pools,
    google_iam_workload_identity_pool_provider.providers
  ]
}
