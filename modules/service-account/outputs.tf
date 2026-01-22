output "service_account_emails" {
  description = "List of created service accounts with their emails"
  value       = { for sa in google_service_account.service_accounts : sa.account_id => sa.email }
}
