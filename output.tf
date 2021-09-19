output "iam_role" {
  value = {}
}

output "assume_role_policy_json" {
  value = data.aws_iam_policy_document.assume_role_policy.json
}