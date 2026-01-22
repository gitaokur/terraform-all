/*  locals {
  service_account = var.service_account
  registry_projects_list = length(var.registry_project_ids) == 0 ? [var.project_id] : var.registry_project_ids
}

# IAM roles for the service account used by the cluster
resource "google_project_iam_member" "cluster_service_account_node_service_account" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${local.service_account}"
}

resource "google_project_iam_member" "cluster_service_account_metric_writer" {
  project = var.project_id
  role    = var.monitoring_metric_writer_role
  member  = "serviceAccount:${local.service_account}"
}

resource "google_project_iam_member" "cluster_service_account_resource_metadata_writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${local.service_account}"
}

# IAM for accessing registry (if enabled)
resource "google_project_iam_member" "cluster_service_account_gcr" {
  for_each = var.grant_registry_access ? toset(local.registry_projects_list) : []
  project  = each.key
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${local.service_account}"
}

resource "google_project_iam_member" "cluster_service_account_artifact_registry" {
  for_each = var.grant_registry_access ? toset(local.registry_projects_list) : []
  project  = each.key
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${local.service_account}"
}

# Fleet project IAM (if enabled)
resource "google_project_service_identity" "fleet_project" {
  count    = var.fleet_project_grant_service_agent ? 1 : 0
  provider = google-beta
  project  = var.fleet_project
  service  = "gkehub.googleapis.com"
}

resource "google_project_iam_member" "service_agent" {
  for_each = var.fleet_project_grant_service_agent ? toset(["roles/gkehub.serviceAgent", "roles/gkehub.crossProjectServiceAgent"]) : []
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_project_service_identity.fleet_project[0].email}"
}
 */