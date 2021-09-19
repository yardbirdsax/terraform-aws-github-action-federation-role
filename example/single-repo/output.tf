output "iam_role_arn" {
  value = module.iam_role.iam_role_arn
}

output "assume_role_policy_json" {
  value = module.iam_role.assume_role_policy_json
}

output "iam_policy_arn" {
  value = aws_iam_policy.policy.arn
}