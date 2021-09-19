terraform {
  required_providers {
    aws = {
      version = "~> 3.54"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}


data "aws_iam_policy_document" "policy" {
  statement {
    actions = [ "ec2:*" ]
    effect = "Allow"
    resources = [ "*" ]
  }
}
resource "aws_iam_policy" "policy" {
  name = "${var.github_org_name}-${var.github_repository_name == "*" ? "all" : var.github_repository_name}-GitHub-Actions"
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "boundary_policy" {
  statement {
    actions = [ "iam:*" ]
    effect = "Deny"
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "boundary_policy" {
  name = "${var.github_org_name}-${var.github_repository_name == "*" ? "all" : var.github_repository_name}-GitHub-Actions-boundary"
  policy = data.aws_iam_policy_document.boundary_policy.json
}

module "iam_role" {
  source = "../../"

  iam_role_name   = var.iam_role_name
  github_org_name = var.github_org_name
  github_repository_name = var.github_repository_name
  github_branch_names = var.github_branch_names
  oidc_provider_arn = var.oidc_provider_arn
  iam_policy_arns = [ aws_iam_policy.policy.arn, "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" ]
  iam_role_boundary_policy_arn = aws_iam_policy.boundary_policy.arn
}