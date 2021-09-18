output "iam_role" {
  value = module.iam_role.iam_role
}

output "oidc_provider" {
  value = module.iam_role.oidc_provider
}