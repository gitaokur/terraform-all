output "app_id" {
  description = "The unique identifier of the App Engine application."
  value       = google_app_engine_application.app.app_id
}

output "default_hostname" {
  description = "The default hostname of the App Engine application."
  value       = google_app_engine_application.app.default_hostname
}

output "service_names" {
  description = "Map of service names to their resource names."
  value       = { for k, v in google_app_engine_standard_app_version.service : k => v.name }
}
