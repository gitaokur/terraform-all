resource "google_compute_instance_template" "tpl" {
  for_each = var.instance_groups

  project      = var.project_id
  name_prefix  = "${each.key}-"
  machine_type = each.value.machine_type

  region = each.value.region

  disk {
    source_image = each.value.source_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
    subnetwork_project = var.project_id

    dynamic "access_config" {
      for_each = each.value.assign_external_ip ? [1] : []
      content {
        # Ephemeral external IP
      }
    }
  }

  metadata = {
    startup-script = each.value.metadata_startup_script
  }

  tags   = each.value.tags
  labels = each.value.labels

  dynamic "service_account" {
    for_each = each.value.service_account != "" ? [1] : []
    content {
      email  = each.value.service_account
      scopes = ["cloud-platform"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  for_each = var.instance_groups

  project            = var.project_id
  name               = each.key
  base_instance_name = each.key
  region             = each.value.region

  version {
    instance_template = google_compute_instance_template.tpl[each.key].self_link
  }

  target_size = each.value.target_size

  named_port {
    name = "http"
    port = 80
  }

  lifecycle {
    create_before_destroy = true
  }
}
