package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/stretchr/testify/assert"
)

const (
	GITHUB_ORG_NAME = "yardbirdsax"
	GITHUB_REPO_NAME = "terraform-aws-github-action-federation-role"
)

func TestRole_SingleRepo(t *testing.T) {
	t.Parallel()
	
	terraformDir := "example/single-repo"
	terraformRootDir := "../"
	expectedClientIDList := fmt.Sprintf("[https://github.com/%s/%s]", GITHUB_ORG_NAME, GITHUB_REPO_NAME)
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

	//iamRole := terraform.OutputMap(t, terraformOptions, "iam_role")
	githubProvider := terraform.OutputMap(t, terraformOptions, "oidc_provider")
	assert.Equal(t, expectedClientIDList, githubProvider["client_id_list"])		
}