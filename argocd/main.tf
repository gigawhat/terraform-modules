resource "kubernetes_namespace" "this" {
  metadata {
    name = "argocd"
  }
  lifecycle {
    ignore_changes = [metadata.0.labels]
  }
}

resource "kubernetes_secret" "this" {
  metadata {
    name      = var.github_repository_name
    namespace = kubernetes_namespace.this.metadata.0.name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    "name"          = var.github_repository_name
    "project"       = "default"
    "type"          = "git"
    "url"           = var.github_repository_ssh_clone_url
    "sshPrivateKey" = chomp(var.private_key_openssh)
  }
  type = "Opaque"
  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.this.metadata.0.name
  version          = var.argocd_chart_version
  depends_on       = [kubernetes_secret.this]
  values = [
    <<EOT
global:
  domain: ${var.argo_domain}
  logging:
    format: json
configs:
  rbac:
    policy.default: role:admin
  secret:
    githubSecret: ${var.github_webhook_secret}
  cm:
    admin.enabled: false
    dex.config: |
      connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${var.github_client_id}
            clientSecret: ${var.github_client_secret}
EOT
  ]
}

resource "helm_release" "argocd-apps" {
  name             = "argocd-apps"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  namespace        = kubernetes_namespace.this.metadata.0.name
  version          = var.argocd_apps_chart_version
  depends_on       = [helm_release.argocd]
  values = [
    <<EOT
applications:
  fleet-infra:
    namespace: ${kubernetes_namespace.this.metadata.0.name}
    project: default
    source:
      repoURL: "${var.github_repository_ssh_clone_url}"
      targetRevision: HEAD
      path: parentapps/${var.cluster_name}
    destination:
      server: "https://kubernetes.default.svc"
      namespace: ${kubernetes_namespace.this.metadata.0.name}
    syncPolicy:
        automated: {}
EOT
  ]
}
