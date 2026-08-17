################################################################################
# Django - AWS Secrets Manager Access using EKS Pod Identity
################################################################################

################################################################################
# Get current AWS account
################################################################################




################################################################################
# Existing Secrets Manager Secret
#
# This secret was created manually in AWS Secrets Manager.
################################################################################

data "aws_secretsmanager_secret" "django_db_secret" {
  name = "django-db-secret"
}


################################################################################
# IAM Role for Django Pod
################################################################################

resource "aws_iam_role" "django_getsecrets" {
  name = "${local.name}-django-getsecrets-role"

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
    Name        = "${local.name}-django-getsecrets-role"
    Environment = var.environment_name
    Component   = "Django Secrets Access"
  }
}


################################################################################
# IAM Policy
#
# Allows Django Pod to read only django-db-secret.
################################################################################

resource "aws_iam_policy" "django_secrets_policy" {

  name = "${local.name}-django-secrets-policy"

  description = "Allow Django Pod to read django-db-secret from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = data.aws_secretsmanager_secret.django_db_secret.arn
      }
    ]
  })

  tags = {
    Name        = "${local.name}-django-secrets-policy"
    Environment = var.environment_name
  }
}


################################################################################
# Attach Secrets Manager Policy to Django IAM Role
################################################################################

resource "aws_iam_role_policy_attachment" "django_secrets_policy_attach" {

  role = aws_iam_role.django_getsecrets.name

  policy_arn = aws_iam_policy.django_secrets_policy.arn
}


################################################################################
# EKS Pod Identity Association
#
# Connects:
#
# Kubernetes:
#   namespace       = default
#   serviceAccount  = django
#
# to:
#
# AWS:
#   django_getsecrets IAM role
################################################################################

resource "aws_eks_pod_identity_association" "django" {

  cluster_name = aws_eks_cluster.main.name

  namespace = "default"

  service_account = "django"

  role_arn = aws_iam_role.django_getsecrets.arn

  depends_on = [
    aws_iam_role_policy_attachment.django_secrets_policy_attach
  ]
}


################################################################################
# Outputs
################################################################################

output "django_pod_identity_role_arn" {
  description = "IAM role ARN used by Django Pod Identity"

  value = aws_iam_role.django_getsecrets.arn
}


output "django_pod_identity_association_id" {
  description = "EKS Pod Identity association ID for Django"

  value = aws_eks_pod_identity_association.django.association_id
}
