resource "google_project_iam_binding" "group_roles" {
  for_each = { for group in var.iam_groups : group.name => group }

  project                 = var.project_id
  role                    = each.value.roles[0]
  members                 = each.value.members
}

# IAM Group Binding (for multiple roles)
# resource "google_project_iam_binding" "group_roles_with_multiple_roles" {
#   for_each = { for group in var.iam_groups : group.name => group }

#   project = var.project_id
#   role    = each.value.roles[0]  # Using the first role as a sample
#   members = each.value.members
# }
