# terraform-aws-github-action-federation-role

This repository contains a Terraform module for creating IAM Roles that can be assumed by GitHub Actions using web federation. Much of the work here is based of the [excellent blog post](https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html) by Aidan Steele.

> **PLEASE NOTE**: This is as-of-yet (19th of September 2021) undocumented functionality, so this module should probably not be used in production environments as GitHub may change things before public release. See [this GitHub Roadmap item](https://github.com/github/roadmap/issues/249) for a current status of the feature.

The module requires that you set up an OIDC provider for GitHub in your AWS Account prior to use, the ARN of which is required by the `oidc_provider_arn` input variable. See below for an example Terraform resource that would provision this.

```hcl
variable "github_owner_list" {
  type = list(string)
  description = "A list of GitHub orgs / users that the OIDC provider will trust."
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

<!--- END_TF_DOCS --->