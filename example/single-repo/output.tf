output "iam_role" {
  value = module.iam_role.iam_role
}

output "assume_role_policy_json" {
  value = module.iam_role.assume_role_policy_json
}

output "iam_policy_arn" {
  value = aws_iam_policy.policy.arn
}