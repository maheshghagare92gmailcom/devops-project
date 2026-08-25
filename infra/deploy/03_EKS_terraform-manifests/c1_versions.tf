terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }

  backend "s3" {
    bucket         = "devops-recipe-app-tf-state-mahesh-eks4"
    key            = "tf-state-eks-deploy"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-recipe-app-tf-state-lock-mahesh"
  }
}

# ---------------------------------------------------------
# AWS Provider
# ---------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}


# ---------------------------------------------------------
# Get EKS Cluster Information
# ---------------------------------------------------------

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.name

  depends_on = [
    aws_eks_cluster.main
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.name

  depends_on = [
    aws_eks_cluster.main
  ]
}


# ---------------------------------------------------------
# Kubernetes Provider
# ---------------------------------------------------------

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.cluster.token
}


# ---------------------------------------------------------
# Helm Provider
# ---------------------------------------------------------

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.cluster.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.cluster.token
  }
}
