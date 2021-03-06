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

variable "oidc_provider_arn" {
  description = "The ARN for the existing OIDC IAM provider for GitHub."
  type        = string
}

variable "iam_policy_arns" {
  description = "A list of IAM Policy ARNs that should be attached to the created IAM Role. Can be not specified if policy attachments will be handled elsewhere."
  type        = list(string)
  default     = []
}

variable "iam_role_boundary_policy_arn" {
  description = "If specified, the policy with the given ARN will be attached to the IAM Role as a boundary policy. If left as null (the default), no boundary policy will be attached."
  type        = string
  default     = null
}