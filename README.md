# terraform-aws-github-action-federation-role

This repository contains a Terraform module for creating IAM Roles that can be assumed by GitHub Actions using web federation. Much of the work here is based off the [excellent blog post](https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html) by Aidan Steele.

> **PLEASE NOTE**: This is as-of-yet (19th of September 2021) undocumented functionality, so this module should probably not be used in production environments as GitHub may change things before public release. See [this GitHub Roadmap item](https://github.com/github/roadmap/issues/249) for a current status of the feature.

The module requires that you set up an OIDC provider for GitHub in your AWS Account prior to use, the ARN of which is required by the `oidc_provider_arn` input variable. See below for an example Terraform resource that would provision this.

```hcl
variable "github_repo_list" {
  type = list(string)
  description = "A list of GitHub orgs / users and repositories that the OIDC provider will trust. This must be in the format of 'org/repo'."
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://vstoken.actions.githubusercontent.com"
  thumbprint_list = [ "a031c46782e6e6c662c2c87c76da9aa62ccabd8e" ]
  client_id_list = formatlist("https://github.com/%s", var.github_owner_list)
}
```

The module deliberately does _not_ include this resource in order to be flexible around how you deploy it. For example, some organizations may wish to keep all definitions of GitHub Action assumed roles in one, tightly controlled repository. In this case, the OIDC provider may well be deployed in the same set of code as the role(s) themelves. In other cases, repository owners themselves may be responsible for writing the deployments to manage their roles; in this case, the provider would have to be kept elsewhere, since there can be only one deployed per AWS Account.

## Module Usage

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.54 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.54 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_branch_names"></a> [github\_branch\_names](#input\_github\_branch\_names) | The names of the branches where actions running will be allowed to assume the role. This defaults to '*', which means that code running in any branch can assume the role. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_github_org_name"></a> [github\_org\_name](#input\_github\_org\_name) | The name of the GitHub user or organization that owns the repository(ies) the role will use. | `string` | n/a | yes |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | The name of the GitHub repository that will be allowed to assume the role. This defaults to '*', which will allow any repository within the org to assume the role. **This is likely not a good use case for most deployments and may be changed in a future release.** | `string` | `"*"` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | A list of IAM Policy ARNs that should be attached to the created IAM Role. Can be not specified if policy attachments will be handled elsewhere. | `list(string)` | `[]` | no |
| <a name="input_iam_role_boundary_policy_arn"></a> [iam\_role\_boundary\_policy\_arn](#input\_iam\_role\_boundary\_policy\_arn) | If specified, the policy with the given ARN will be attached to the IAM Role as a boundary policy. If left as null (the default), no boundary policy will be attached. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | The name of the IAM Role to be created. | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN for the existing OIDC IAM provider for GitHub. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assume_role_policy_json"></a> [assume\_role\_policy\_json](#output\_assume\_role\_policy\_json) | The JSON result of the assume role policy document. This is mostly used for testing purposes. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the generated IAM Role. |

<!--- END_TF_DOCS --->
