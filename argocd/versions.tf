terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
  }
}
