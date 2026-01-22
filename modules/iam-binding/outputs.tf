output "iam_bindings" {
  description = "IAM bindings applied"
  value = [for b in google_project_iam_member.bindings : {
    member = b.member
    role   = b.role
  }]
}
