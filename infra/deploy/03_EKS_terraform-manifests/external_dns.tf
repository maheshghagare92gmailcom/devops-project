################################################################################
# ExternalDNS
# Route 53 DNS management using EKS Pod Identity
################################################################################

locals {
  external_dns_namespace = "kube-system"
  external_dns_sa        = "external-dns"
  external_dns_role      = "${local.name}-external-dns"
}


################################################################################
# IAM Policy
################################################################################

resource "aws_iam_policy" "external_dns" {
  name        = "${local.name}-ExternalDNS"
  description = "IAM policy for ExternalDNS to manage Route 53 records"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets"
        ]

        Resource = aws_route53_zone.main.arn
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}


################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "external_dns" {
  name = local.external_dns_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name        = local.external_dns_role
    Environment = var.environment_name
  }
}


################################################################################
# Attach IAM Policy
################################################################################

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}


################################################################################
# EKS Pod Identity Association
################################################################################

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = local.external_dns_namespace
  service_account = local.external_dns_sa
  role_arn        = aws_iam_role.external_dns.arn
}


################################################################################
# ExternalDNS Helm Release
################################################################################

resource "helm_release" "external_dns" {
  name = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  namespace        = local.external_dns_namespace
  create_namespace = false

  set = [
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "aws.region"
      value = "us-east-1"
    },
    {
      name  = "txtOwnerId"
      value = aws_route53_zone.main.zone_id
    },
    {
      name  = "domainFilters[0]"
      value = "maheshdevops.shop"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "registry"
      value = "txt"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = local.external_dns_sa
    }
  ]

  depends_on = [
    aws_eks_pod_identity_association.external_dns,
    aws_iam_role_policy_attachment.external_dns
  ]
}
