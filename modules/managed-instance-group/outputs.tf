output "instance_group_managers" {
  description = "The instance group manager resources"
  value       = google_compute_region_instance_group_manager.mig
}

output "instance_groups" {
  description = "The instance group URLs"
  value       = { for k, v in google_compute_region_instance_group_manager.mig : k => v.instance_group }
}
