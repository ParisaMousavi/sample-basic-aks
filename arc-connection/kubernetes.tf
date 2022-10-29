resource "kubernetes_service_account" "arc_user" {
  metadata {
    name = "terraform-arc-user"
  }
}


resource "kubernetes_cluster_role_binding" "arc_user" {
  metadata {
    name = "terraform-arc-user-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.arc_user.metadata.0.name
    namespace = "*"
  }
}


resource "kubernetes_secret" "arc_user" {
  metadata {
    name = "terraform-arc-user-secret"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.arc_user.metadata.0.name
    }
  }

  type = "kubernetes.io/service-account-token"
}

output "arc_service_account_token" {
  sensitive = true
  value     = kubernetes_secret.arc_user.data.token
}
