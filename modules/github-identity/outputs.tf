output "pool_names" {
  description = "Workload identity pools created"
  value       = [for pool in google_iam_workload_identity_pool.pools : pool.name]
}

output "provider_names" {
  description = "OIDC providers created"
  value       = [for provider in google_iam_workload_identity_pool_provider.providers : provider.name]
}
