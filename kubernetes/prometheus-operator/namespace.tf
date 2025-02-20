resource "kubernetes_namespace" "this" {
  metadata {
    name = "prometheus-operator"
  }
}
