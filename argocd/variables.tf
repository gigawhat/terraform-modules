variable "github_repository_name" {
  description = "Github Repository name of the parent repository."
  type        = string
}

variable "github_repository_ssh_clone_url" {
  description = "SSH clone URL of the parent repository."
  type        = string
}

variable "private_key_openssh" {
  description = "Private key in OpenSSH format."
  type        = string
}

variable "argocd_chart_version" {
  description = "ArgoCD chart version."
  type        = string
  default     = "7.4.3"
}

variable "argocd_apps_chart_version" {
  description = "ArgoCD Apps chart version."
  type        = string
  default     = "2.0.0"
}

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "github_client_id" {
  description = "Github OAuth App Client ID."
  type        = string
}

variable "github_client_secret" {
  description = "Github OAuth App Client Secret."
  type        = string
  sensitive   = true
}

variable "github_webhook_secret" {
  description = "Github Webhook Secret."
  type        = string
  sensitive   = true
}

variable "argo_domain" {
  description = "Domain name for ArgoCD."
  type        = string
}
