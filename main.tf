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
  repository_ref_list = [ 
    for b in var.github_branch_names:
      "repo:${local.repository_slug}:${b == "*" ? "*" : "ref:refs/heads/${b}"}"
  ]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    principals {
      type = "Federated"
      identifiers = [ var.oidc_provider_arn  ]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = local.repository_ref_list
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary = var.iam_role_boundary_policy_arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count = length(var.iam_policy_arns)
  role = aws_iam_role.iam_role.name
  policy_arn = var.iam_policy_arns[count.index]
}