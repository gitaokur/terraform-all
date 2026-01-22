output "load_balancer_ip" {
  value = module.load_balancer.lb_ip
}

output "storage_buckets" {
  value = [for b in var.buckets : b.name]
}
