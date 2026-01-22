output "iam_groups" {
  value = {
    for group in google_project_iam_binding.group_roles :
    tostring(join(",", group.members)) => group.role
  }
}
