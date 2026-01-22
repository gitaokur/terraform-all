output "load_balancer_ip" {
  description = "The IP address of the Load Balancer"
  value       = module.load_balancer.lb_ip
}

output "artifact_repository_names" {
  description = "Names of the created Artifact Registry repositories"
  value       = module.artifact_registry.artifact_repositories
}

output "cloud_run_service_urls" {
  description = "List of Cloud Run service URLs"
  value       = { for k, v in module.cloud_run.service_urls : k => v }
}
