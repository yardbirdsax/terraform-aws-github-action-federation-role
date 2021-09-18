output "iam_role" {
  value = {}
}

output "oidc_provider" {
  value = {
    client_id_list = aws_iam_openid_connect_provider.github.client_id_list
  }
}