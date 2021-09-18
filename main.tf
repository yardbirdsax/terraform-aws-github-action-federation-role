terraform {
  required_providers {
    aws = {
      version = "~> 3.54"
      source  = "hashicorp/aws"
    }
  }
}

locals {
  repository_slug = "${var.github_org_name}/${var.github_repository_name}"
  repository_slug_list = [ 
    for b in var.github_branch_names:
      "repo:${local.repository_slug}:${b == "*" ? "*" : "ref:refs/heads/${b}"}"
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://vstoken.actions.githubusercontent.com"
  thumbprint_list = [ "a031c46782e6e6c662c2c87c76da9aa62ccabd8e" ]
  client_id_list = ["https://github.com/${local.repository_slug}"]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
  }
}