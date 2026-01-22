output "security_policy_name" {
  value       = google_compute_security_policy.default.name
  description = "The name of the security policy"
}

output "security_policy_id" {
  value       = google_compute_security_policy.default.id
  description = "The ID of the security policy"
}
