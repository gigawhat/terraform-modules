#!/bin/bash

set -eux

kubectl kustomize . > bundle.yaml

# Convert the yaml to tf
tfk8s -f bundle.yaml -o ../../kubernetes/prometheus-operator/main.tf


# Get the CRDs from the bundle and convert them to tf
yq '. |  select(.kind == "CustomResourceDefinition")' bundle.yaml | tfk8s -o ../../kubernetes/prometheus-operator-crds/main.tf
