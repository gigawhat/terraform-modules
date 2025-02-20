package test

import (
	"errors"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestK8sPromOperator(t *testing.T) {
	t.Parallel()

	kindCluster := newKindCluster(t)
	kindCluster.create()
	defer kindCluster.delete()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../kubernetes/prometheus-operator/examples/simple",
		EnvVars: map[string]string{
			"KUBE_CTX": kindCluster.ctx,
		},
	})

	namespace := "prometheus-operator"
	deploymentName := "prometheus-operator"

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	k8sOptions := k8s.NewKubectlOptions(kindCluster.ctx, "", namespace)

	// Check if the namespace exists
	k8s.GetNamespace(t, k8sOptions, namespace)

	// Check if the deployment exists
	retry.DoWithRetry(
		t,
		"Wait for the deployment to be ready",
		10,
		5*time.Second,
		func() (string, error) {
			s, err := k8s.GetDeploymentE(t, k8sOptions, deploymentName)
			if err != nil {
				return "", err
			}
			if s.Status.ReadyReplicas == s.Status.Replicas {
				return "ready", nil
			}
			return "", errors.New("deployment not ready")

		})

}
