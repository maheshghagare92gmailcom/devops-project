# ==============================================================================
# ARGO CD
# ==============================================================================
# Argo CD is installed into the EKS cluster using Terraform + Helm.
#
# This replaces:
#
# kubectl create namespace argocd
# kubectl apply -n argocd -f \
#   https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#
# Terraform manages:
#   1. argocd namespace
#   2. Argo CD Helm release
# ==============================================================================


# ------------------------------------------------------------------------------
# Argo CD Namespace
# ------------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "argocd" {

  metadata {
    name = "argocd"
  }
}


# ------------------------------------------------------------------------------
# Argo CD Helm Release
# ------------------------------------------------------------------------------

resource "helm_release" "argocd" {

  name = "argocd"

  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  # --------------------------------------------------------------------------
  # Argo CD version
  #
  # Leave this commented initially so Helm installs the current chart
  # version available from the repository.
  #
  # Once everything is working, pin a specific version for reproducibility.
  # --------------------------------------------------------------------------

  # version = "x.x.x"


  # Namespace is already created above by Terraform.
  create_namespace = false


  # --------------------------------------------------------------------------
  # Wait for Argo CD resources to become ready
  # --------------------------------------------------------------------------

  wait = true

  timeout = 600


  # --------------------------------------------------------------------------
  # Terraform dependency
  #
  # Namespace must exist before Helm installs Argo CD.
  # --------------------------------------------------------------------------

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}
