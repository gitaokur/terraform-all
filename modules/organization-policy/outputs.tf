output "org_policies" {
  description = "List of applied Organization Policies"
  value       = [for policy in google_org_policy_policy.org_policies : policy.name]
}