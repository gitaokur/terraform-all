output "artifact_repositories" {
  description = "List of created Artifact Registry repositories"
  value       = { for k, v in google_artifact_registry_repository.repo : k => v.name }
}
