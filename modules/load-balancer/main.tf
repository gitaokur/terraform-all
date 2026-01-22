locals {
  create_https_proxy = var.ssl && (length(var.ssl_certificates) > 0 || var.create_ssl_certificate || length(var.managed_ssl_certificate_domains) > 0)
}

resource "google_compute_global_address" "lb_ip" {
  project      = var.project_id
  name         = var.lb_name
  address_type = "EXTERNAL"
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "${var.lb_name}-load-balancer"
  default_service = google_compute_backend_service.default[keys(var.backends)[0]].self_link
}

resource "google_compute_url_map" "https_redirect" {
  project = var.project_id
  count   = var.https_redirect ? 1 : 0
  name    = "${var.lb_name}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  count            = local.create_https_proxy ? 1 : 0
  project          = var.project_id
  name             = "${var.lb_name}-https-proxy"
  ssl_certificates = compact(concat(
    var.ssl_certificates,
    var.create_ssl_certificate ? google_compute_ssl_certificate.default[*].self_link : [],
    length(var.managed_ssl_certificate_domains) > 0 ? google_compute_managed_ssl_certificate.default[*].self_link : [],
  ))
  url_map          = google_compute_url_map.url_map.id
  ssl_policy       = var.ssl_policy
}

resource "google_compute_target_http_proxy" "http_proxy" {
  project = var.project_id
  name    = "${var.lb_name}-http-proxy"
  url_map = var.https_redirect && local.create_https_proxy ? google_compute_url_map.https_redirect[0].id : google_compute_url_map.url_map.id
}

resource "google_compute_ssl_certificate" "default" {
  project     = var.project_id
  count       = var.ssl && var.create_ssl_certificate ? 1 : 0
  name_prefix = "${var.lb_name}-certificate-"
  private_key = var.private_key
  certificate = var.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "certificate" {
  count       = var.random_certificate_suffix == true ? 1 : 0
  byte_length = 4
  prefix      = "${var.lb_name}-cert-"

  keepers = {
    domains = join(",", var.managed_ssl_certificate_domains)
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  project  = var.project_id
  count    = var.ssl && length(var.managed_ssl_certificate_domains) > 0 ? 1 : 0
  name     = var.random_certificate_suffix == true ? random_id.certificate[0].hex : "${var.lb_name}-cert"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.managed_ssl_certificate_domains
  }
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count                 = local.create_https_proxy ? 1 : 0
  project               = var.project_id
  name                  = "${var.lb_name}-https"
  target                = google_compute_target_https_proxy.https_proxy[0].id
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  project               = var.project_id
  name                  = "${var.lb_name}-http"
  target                = google_compute_target_http_proxy.http_proxy.id
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_backend_service" "default" {
  for_each              = var.backends
  project               = var.project_id
  name                  = var.lb_name
  enable_cdn            = lookup(each.value, "enable_cdn", false)
  session_affinity      = lookup(each.value, "session_affinity", null)
  #for cloud armor we probably will change security policy ->   security_policy = module.cloud_armor.security_policy_id
  security_policy       = var.security_policy
  #security_policy       = each.value["security_policy"] == "" ? null : (each.value["security_policy"] == null ? var.security_policy : each.value.security_policy)
  load_balancing_scheme = "EXTERNAL_MANAGED"
  custom_request_headers  = lookup(each.value, "custom_request_headers", [])
  custom_response_headers = lookup(each.value, "custom_response_headers", [])

  dynamic "backend" {
    for_each = toset(each.value["groups"])
    content {
      description = lookup(backend.value, "description", null)
      group       = backend.value["group"]

      balancing_mode               = lookup(backend.value, "balancing_mode", null)
      capacity_scaler              = lookup(backend.value, "capacity_scaler", null)
      max_utilization              = lookup(backend.value, "max_utilization", null)
      max_rate                     = lookup(backend.value, "max_rate", null)
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance", null)
      max_connections              = lookup(backend.value, "max_connections", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_connections_per_endpoint = lookup(backend.value, "max_connections_per_endpoint", null)
    }
  }
  dynamic "backend" {
    for_each = toset(each.value["serverless_neg_backends"])
    content {
      group = google_compute_region_network_endpoint_group.serverless_negs["neg-${each.key}-${backend.value.region}-${backend.value.service.name}"].id
    }
  }
  dynamic "log_config" {
    for_each = lookup(lookup(each.value, "log_config", {}), "enable", true) ? [1] : []
    content {
      enable      = lookup(lookup(each.value, "log_config", {}), "enable", true)
      sample_rate = lookup(lookup(each.value, "log_config", {}), "sample_rate", "1.0")
    }
  }
  dynamic "iap" {
    for_each = var.iap_config.enabled ? [1] : []
    content {
      oauth2_client_id     = lookup(var.iap_config, "oauth2_client_id", "")
      enabled              = var.iap_config.enabled
      oauth2_client_secret = lookup(var.iap_config, "oauth2_client_secret", "")
    }
  }

  health_checks = length(each.value.serverless_neg_backends) > 0 ? [] : [google_compute_health_check.default[each.key].id]
}

resource "google_compute_health_check" "default" {
  for_each = var.backends
  project  = var.project_id
  name     = "${var.lb_name}-hc-${each.key}"

  check_interval_sec = 5
  timeout_sec        = 5

  tcp_health_check {
    port = 80
  }
}
  resource "google_compute_region_network_endpoint_group" "serverless_negs" {
  for_each = merge([
    for backend_index, backend in var.backends : {
      for serverless_neg_backend in backend.serverless_neg_backends :
      "neg-${backend_index}-${serverless_neg_backend.region}-${serverless_neg_backend.service.name}" => serverless_neg_backend
    }
  ]...)

  provider              = google-beta
  project               = var.project_id
  name                  = each.key
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  dynamic "cloud_run" {
    for_each = each.value.type == "cloud-run" ? [1] : []
    content {
      service = each.value.service.name
    }
  }

  dynamic "cloud_function" {
    for_each = each.value.type == "cloud-function" ? [1] : []
    content {
      function = each.value.service.name
    }
  }

  dynamic "app_engine" {
    for_each = each.value.type == "app-engine" ? [1] : []
    content {
      service = each.value.service.name
      version = each.value.service.version
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  }