package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestK8sPromOperatorCRD(t *testing.T) {
	t.Parallel()

	kindCluster := newKindCluster(t)
	kindCluster.create()
	defer kindCluster.delete()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../kubernetes/prometheus-operator-crds/examples/simple",
		EnvVars: map[string]string{
			"KUBE_CTX": kindCluster.ctx,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	k8sOptions := k8s.NewKubectlOptions(kindCluster.ctx, "", "")

	// Check if the CRDs exist
	crds := []string{
		"alertmanagers.monitoring.coreos.com",
		"podmonitors.monitoring.coreos.com",
		"prometheuses.monitoring.coreos.com",
		"prometheusrules.monitoring.coreos.com",
		"servicemonitors.monitoring.coreos.com",
		"thanosrulers.monitoring.coreos.com",
	}
	output, err := k8s.RunKubectlAndGetOutputE(t, k8sOptions, "get", "crd")
	if err != nil {
		t.Fatalf("Error getting CRD: %v", err)
	}
	if output == "" {
		t.Fatalf("No CRDs found")
	}

	for _, crd := range crds {
		if !strings.Contains(output, crd) {
			t.Fatalf("CRD %s not found", crd)
		}
	}
}
