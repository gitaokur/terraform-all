output "secret_names" {
  description = "List of created secret names"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.secret_id }
}

output "secret_versions" {
  description = "List of secret versions"
  value       = { for k, v in google_secret_manager_secret_version.secret_versions : k => v.version }
}
