output "iam_role_arn" {
  value = aws_iam_role.iam_role.arn
  description = "The ARN of the generated IAM Role."
}

output "assume_role_policy_json" {
  value = data.aws_iam_policy_document.assume_role_policy.json
  description = "The JSON result of the assume role policy document. This is mostly used for testing purposes."
}