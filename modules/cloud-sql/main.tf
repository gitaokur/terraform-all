resource "google_sql_database_instance" "default" {
  for_each         = var.database
  project          = var.project_id
  name             = each.value.instance_name
  database_version = each.value.database_version
  region           = each.value.region

  settings {
    tier = each.value.tier
    availability_type = each.value.availability_type

    ip_configuration {
      private_network = var.vpc_self_link
      enable_private_path_for_google_cloud_services = true
      ipv4_enabled = var.enable_public_ip # to disable or enable public ip addresses: default value is disabled.
    }

    dynamic "database_flags" {
      for_each = each.value.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    insights_config {
      query_insights_enabled  = each.value.insights_config.query_insights_enabled
      query_string_length     = each.value.insights_config.query_string_length
      record_application_tags = each.value.insights_config.record_application_tags
      record_client_address   = each.value.insights_config.record_client_address
    }


      dynamic "authorized_networks" {
        for_each = lookup(each.value, "authorized_networks", [])
        content {
          name  = authorized_networks.value["name"]
          value = authorized_networks.value["value"]
        }
      }
    }

    backup_configuration {
      enabled            = lookup(each.value, "backup_enabled", true)
      binary_log_enabled = lookup(each.value, "binary_log_enabled", false)
    }

    maintenance_window {
      day          = var.maintenance_day #day of the week, 1 to 7.
      hour         = var.maintenance_hour #0-23
      update_track = var.update_track
    }

    disk_autoresize = true
    disk_size       = lookup(each.value, "disk_size", 50)
    disk_type       = "PD_SSD"
  }

  deletion_protection = lookup(each.value, "deletion_protection", true)
}

resource "google_sql_database" "default" {
  for_each = var.database
  project  = var.project_id
  name     = each.value.database_name
  instance = google_sql_database_instance.default[each.key].name
}

resource "google_sql_user" "default" {
  for_each = var.database
  project  = var.project_id
  name     = each.value.db_user
  instance = google_sql_database_instance.default[each.key].name
  password = each.value.db_password
}
