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

module "iam_role" {
  source = "../../"

  iam_role_name   = var.iam_role_name
  github_org_name = var.github_org_name
  github_repository_name = var.github_repository_name
  github_branch_names = var.github_branch_names
}