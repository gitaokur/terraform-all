resource "google_firestore_database" "database" {
  project                           = var.project_id
  name                              = var.firestore.name
  location_id                       = var.firestore.location_id
  type                              = var.firestore.type
  point_in_time_recovery_enablement = var.firestore.point_in_time_recovery_enablement
  deletion_policy                   = var.firestore.deletion_policy
}

resource "google_firestore_backup_schedule" "weekly-backup" {
  project  = var.project_id
  database = google_firestore_database.database.name

  retention = "8467200s" // 14 weeks (maximum possible retention)

  weekly_recurrence {
    day = "SUNDAY"
  }
}