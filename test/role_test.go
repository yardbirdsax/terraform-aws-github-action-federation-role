package test

import (
	//"fmt"
	"context"
	"os"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/iam"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	//"github.com/stretchr/testify/assert"
)

const (
	GITHUB_ORG_NAME = "yardbirdsax"
	GITHUB_REPO_NAME = "terraform-aws-github-action-federation-role"
	AWS_OIDC_PROVIDER_ARN = "arn:aws:iam::068845349622:oidc-provider/vstoken.actions.githubusercontent.com"
)

func TestRole_SingleRepo(t *testing.T) {
	t.Parallel()
	
	terraformDir := "example/single-repo"
	terraformRootDir := "../"
	iamRoleName := strings.ToLower(random.UniqueId())
	region := aws.GetRandomStableRegion(t, nil, nil)	
	
	tempDir := test_structure.CopyTerraformFolderToTemp(t, terraformRootDir, terraformDir)
	
	terraformOptions := &terraform.Options{
		TerraformDir: tempDir,
		Vars: map[string]interface{}{
			"github_org_name": GITHUB_ORG_NAME,
			"github_repository_name": GITHUB_REPO_NAME,
			"github_branch_names": []string{ "*" },
			"iam_role_name": iamRoleName,
			"region": region,
			"oidc_provider_arn": AWS_OIDC_PROVIDER_ARN,
		},
	}

	defer test_structure.RunTestStage(t, "terraform_destroy", func() {
		_ = terraform.Destroy(t, terraformOptions)
		err := os.RemoveAll(tempDir)
		if err != nil {
			t.Fatal(err)
		}
	})
	test_structure.RunTestStage(t, "terraform_apply", func() {
		_ = terraform.InitAndApplyAndIdempotent(t, terraformOptions)
	})

	ctx := context.Background()
	awsConfig, err := config.LoadDefaultConfig(ctx)
	require.Nil(t, err, "Error trying to load default AWS configuration.")

	test_structure.RunTestStage(t, "iam_role_test", func() {
		iamClient := iam.NewFromConfig(awsConfig)

		// Assert the created role ARN is an output.
		assert.NotEmpty(t, terraform.Output(t, terraformOptions, "iam_role_arn"))
		
		// TODO: Test IAM Role Assume Role Policy
		
		// Assert the specified policies are attached to the Role.
		iamPolicyOutput, err := iamClient.ListAttachedRolePolicies(ctx, &iam.ListAttachedRolePoliciesInput{
			RoleName: &iamRoleName,
		})
		require.Nil(t, err)
		iamPolicies := iamPolicyOutput.AttachedPolicies
		var actualIAMPolicyARNs []string
		for _, v := range(iamPolicies) {
			actualIAMPolicyARNs = append(actualIAMPolicyARNs, *v.PolicyArn)
		}
		createdIAMPolicyARN := terraform.Output(t, terraformOptions, "iam_policy_arn")
		awsIAMPolicyARN := "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
		expectedPolicyARNs := []string{
			awsIAMPolicyARN,
			createdIAMPolicyARN,
		}
		assert.ElementsMatch(t, expectedPolicyARNs, actualIAMPolicyARNs)
		
		// Assert the specified boundary policy is attached to the Role
		expectedBoundaryIAMPolicyARN := terraform.Output(t, terraformOptions, "boundary_iam_policy_arn")
		iamRole, err := iamClient.GetRole(ctx, &iam.GetRoleInput{
			RoleName: &iamRoleName,
		})
		require.Nil(t, err)
		assert.NotNil(t, iamRole.Role.PermissionsBoundary)
		actualBoundaryIAMPolicyARN := *iamRole.Role.PermissionsBoundary.PermissionsBoundaryArn
		assert.Equal(t, expectedBoundaryIAMPolicyARN, actualBoundaryIAMPolicyARN)
	})
}