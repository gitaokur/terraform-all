resource "google_cloud_run_v2_service" "service" {
  for_each = { for svc in var.services : svc.name => svc }

  name     = each.value.name
  location = each.value.region
  project  = var.project_id
  deletion_protection = false  # Set to true if needed

  template {
    dynamic "scaling" {
      for_each = each.value.min_instances != null || each.value.max_instances != null ? [1] : []
      content {
        min_instance_count = each.value.min_instances
        max_instance_count = each.value.max_instances
    }
  }

  labels = each.value.labels
  timeout = each.value.timeout
    containers {
      image = each.value.image

      resources {
        limits = {
          cpu    = tostring(each.value.cpu)
          memory = each.value.memory
        }
      }

      dynamic "env" {
        for_each = each.value.env_vars != null ? each.value.env_vars : []
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
      dynamic "env" {
          for_each = each.value.env_secret_vars
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value.secret
                version = env.value.version
              }
            }
          }
        }
    }
    
    dynamic "cloud_sql_instance" {
      for_each = each.value.cloud_sql_instances
      content {
        instances = [cloud_sql_instance.value]
      }
    }

    dynamic "vpc_access" {
          for_each = each.value.vpc_connector != null && each.value.vpc_connector != "" ? [1] : []
          content {
              connector = each.value.vpc_connector
              egress    = "ALL_TRAFFIC"
          }
    }

    service_account                      = each.value.service_account
    max_instance_request_concurrency     = each.value.concurrency

    dynamic "startup_probe" {
      for_each = each.value.startup_probe != null ? [1] : []
      content {
        timeout_seconds   = each.value.startup_probe.timeout_seconds
        period_seconds    = each.value.startup_probe.period_seconds
        failure_threshold = each.value.startup_probe.failure_threshold
        dynamic "tcp_socket" {
          for_each = each.value.startup_probe.tcp_socket != null ? [1] : []
          content {
            port = each.value.startup_probe.tcp_socket.port
          }
        }
        dynamic "http_get" {
          for_each = each.value.startup_probe.http_get != null ? [1] : []
          content {
            path = each.value.startup_probe.http_get.path
            port = each.value.startup_probe.http_get.port
          }
        }
      }
    }

    dynamic "liveness_probe" {
      for_each = each.value.liveness_probe != null ? [1] : []
      content {
        timeout_seconds   = each.value.liveness_probe.timeout_seconds
        period_seconds    = each.value.liveness_probe.period_seconds
        failure_threshold = each.value.liveness_probe.failure_threshold
        dynamic "http_get" {
          for_each = each.value.liveness_probe.http_get != null ? [1] : []
          content {
            path = each.value.liveness_probe.http_get.path
            port = each.value.liveness_probe.http_get.port
          }
        }
      }
    }

    dynamic "network_interfaces" {
      for_each = each.value.direct_vpc_egress != null ? [1] : []
      content {
        network    = each.value.direct_vpc_egress.network
        subnetwork = each.value.direct_vpc_egress.subnetwork
      }
    }
  } 
    ingress = each.value.ingress
    dynamic "traffic" {
    for_each = var.traffic
    content {
      percent  = traffic.value.percent
      type     = traffic.value.type
      revision = traffic.value.revision
      tag      = traffic.value.tag
    }
  }
}


resource "google_cloud_run_service_iam_member" "allow_public" {
  for_each = { for svc in var.services : svc.name => svc if svc.allow_unauthenticated }

  location = each.value.region
  project  = var.project_id
  service  = google_cloud_run_v2_service.service[each.key].name  # Updated reference
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "internal_access" { #for cloud run ingress option, if necessary
  for_each = { for svc in var.services : svc.name => svc if svc.ingress == "internal" }

  location = each.value.region
  project  = var.project_id
  service  = google_cloud_run_v2_service.service[each.key].name
  role     = "roles/run.invoker"
  member   = "user:aokur@globalit.com.tr" #for more restricted access, we could define a iam group here.
}


resource "google_cloud_run_service_iam_member" "additional_iam" {
  for_each = {
    for svc in var.services : svc.name => svc if svc.iam_bindings != null
  }

  location = each.value.region
  project  = var.project_id
  service  = google_cloud_run_v2_service.service[each.key].name  # Updated reference
  role     = each.value.iam_bindings[0].role
  member   = each.value.iam_bindings[0].member
}
