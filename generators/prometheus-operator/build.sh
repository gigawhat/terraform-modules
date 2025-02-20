#!/bin/bash

set -eux

# render the kustomize bundle
kubectl kustomize . > bundle.yaml

# Convert the yaml to tf
tfk8s -f bundle.yaml -o ../../kubernetes/prometheus-operator/main.tf

# Replace the namespace with the kubernetes_namespace.this.metadata.0.name. This ensures that the namespace is created before the operator is deployed
sed -i -e 's/"namespace" = "prometheus-operator"/"namespace" = kubernetes_namespace.this.metadata.0.name/g' ../../kubernetes/prometheus-operator/main.tf

# Get the CRDs from the bundle and convert them to tf
yq '. |  select(.kind == "CustomResourceDefinition")' bundle.yaml | tfk8s -o ../../kubernetes/prometheus-operator-crds/main.tf
