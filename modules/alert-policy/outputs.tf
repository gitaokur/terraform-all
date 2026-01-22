output "uptime_check_ids" {
  value = { for k, v in google_monitoring_uptime_check_config.uptime_checks : k => v.id }
}