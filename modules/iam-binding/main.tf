locals {
  expanded_bindings = flatten([
    for b in var.bindings : [
      for r in b.role : {
        member = b.member
        role   = r
      }
    ]
  ])
}

resource "google_project_iam_member" "bindings" {
  for_each = {
    for b in local.expanded_bindings :
    "${b.member}-${b.role}" => b
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
