variable "iam_role_name" {
  description = "The name of the IAM Role to be created."
  type        = string
}

variable "github_org_name" {
  description = "The name of the GitHub user or organization that owns the repository(ies) the role will use."
  type        = string
}

variable "github_repository_name" {
  description = "The name of the GitHub repository that will be allowed to assume the role. This defaults to '*', which will allow any repository within the org to assume the role. **This is likely not a good use case for most deployments and may be changed in a future release.**"
  default     = "*"
  type        = string 
}

variable "github_branch_names" {
  description = "The names of the branches where actions running will be allowed to assume the role. This defaults to '*', which means that code running in any branch can assume the role."
  default     = ["*"]
  type        = list(string)
}

variable "region" {
  description = "The name of the AWS region to deploy the resources in."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN for the existing OIDC IAM provider for GitHub."
  type        = string
}