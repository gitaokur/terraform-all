resource "google_service_account" "service_accounts" {
  for_each     = { for account in var.service_accounts : account.name => account }
  account_id   = each.value.name
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = {
    for account in flatten([for sa in var.service_accounts : [for role in sa.roles : { key = "${sa.name}-${role}", role = role, account_email = "serviceAccount:${sa.name}@${var.project_id}.iam.gserviceaccount.com" }]]) :
    account.key => account
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.account_email
}
