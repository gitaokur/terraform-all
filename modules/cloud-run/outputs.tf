# Output for Cloud Run Service URLs
output "service_urls" {
  description = "The URLs of the Cloud Run services"
  value = {
    for svc, service in google_cloud_run_v2_service.service :
    svc => service.uri
  }
}
