output "connection_names" {
  description = "List of GitHub connection names"
  value       = [for conn in google_cloudbuildv2_connection.github_connection : conn.name]
}

output "connection_locations" {
  description = "List of regions where connections are created"
  value       = [for conn in google_cloudbuildv2_connection.github_connection : conn.location]
}

output "connection_installation_ids" {
  description = "Installation IDs for the GitHub connections"
  value       = [for conn in google_cloudbuildv2_connection.github_connection : conn.github_config[0].app_installation_id]
}

output "repo_names" {
  description = "Names of the registered GitHub repositories"
  value       = [for repo in google_cloudbuildv2_repository.repos : repo.name]
}


output "trigger_names" {
  description = "Cloud Build triggers created"
  value       = [for trigger in google_cloudbuild_trigger.triggers : trigger.name]
}
