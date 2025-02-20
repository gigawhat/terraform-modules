package test

import (
	"math/rand"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/shell"
)

type kindCluster struct {
	name string
	ctx  string
	t    *testing.T
}

// randomString generates a random string of length n using the characters in charset
func randomString(length int) string {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	const charset = "abcdefghijklmnopqrstuvwxyz"
	result := make([]byte, length)
	for i := range result {
		result[i] = charset[r.Intn(len(charset))]
	}
	return string(result)
}

// newKindCluster creates a new kindCluster object
func newKindCluster(t *testing.T) *kindCluster {
	n := randomString(5)
	return &kindCluster{
		name: n,
		ctx:  "kind-" + n,
		t:    t,
	}
}

// create creates a new kind cluster
func (k *kindCluster) create() {
	shell.RunCommand(k.t, shell.Command{
		Command: "kind",
		Args:    []string{"create", "cluster", "--name", k.name},
	})
}

// delete deletes the kind cluster
func (k *kindCluster) delete() {
	shell.RunCommand(k.t, shell.Command{
		Command: "kind",
		Args:    []string{"delete", "cluster", "--name", k.name},
	})
}
