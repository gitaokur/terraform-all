output "lb_ip" {
  value       = google_compute_global_address.lb_ip.address
  description = "The IP address of the load balancer"
}
