################################################################################
# EFS File System
################################################################################

resource "aws_efs_file_system" "django" {
  creation_token = "${local.name}-django-efs"

  encrypted = false

  tags = {
    Name        = "${local.name}-django-efs"
    Environment = var.environment_name
  }
}


################################################################################
# EFS Security Group
################################################################################

resource "aws_security_group" "efs" {
  name        = "${local.name}-efs-sg"
  description = "Allow NFS access from EKS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "NFS from EKS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"

    security_groups = [
      aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-efs-sg"
  }
}


################################################################################
# EFS Mount Targets
################################################################################
# Creates one mount target in every private subnet supplied by the VPC
# Terraform remote state.
################################################################################

resource "aws_efs_mount_target" "private" {
  for_each = toset(
    data.terraform_remote_state.vpc.outputs.private_subnet_ids
  )

  file_system_id = aws_efs_file_system.django.id

  subnet_id = each.value

  security_groups = [
    aws_security_group.efs.id
  ]
}


################################################################################
# IAM Trust Policy for EKS Pod Identity
################################################################################

data "aws_iam_policy_document" "efs_csi_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}


################################################################################
# IAM Role for EFS CSI Driver
################################################################################

resource "aws_iam_role" "efs_csi" {
  name = "${local.name}-efs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role.json

  tags = {
    Name        = "${local.name}-efs-csi-role"
    Environment = var.environment_name
    Component   = "EFS CSI Driver"
  }
}


################################################################################
# Attach AWS Managed EFS CSI Policy
################################################################################

resource "aws_iam_role_policy_attachment" "efs_csi" {
  role = aws_iam_role.efs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


################################################################################
# EKS Pod Identity Association
################################################################################
# The EFS CSI controller will use this IAM role.
#
# Kubernetes ServiceAccount:
# efs-csi-controller-sa
#
# Namespace:
# kube-system
################################################################################

resource "aws_eks_pod_identity_association" "efs_csi" {
  cluster_name = aws_eks_cluster.main.name

  namespace = "kube-system"

  service_account = "efs-csi-controller-sa"

  role_arn = aws_iam_role.efs_csi.arn

  depends_on = [
    aws_iam_role_policy_attachment.efs_csi,
    aws_eks_addon.podidentity
  ]
}


################################################################################
# EFS CSI Driver
################################################################################

resource "helm_release" "efs_csi" {
  name = "aws-efs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"

  chart = "aws-efs-csi-driver"

  namespace = "kube-system"

  create_namespace = false

  dependency_update = true

  wait = true

  timeout = 600

  cleanup_on_fail = true

  depends_on = [
    aws_eks_pod_identity_association.efs_csi,
    aws_efs_mount_target.private
  ]

  set = [
    {
      name  = "controller.serviceAccount.create"
      value = "true"
    },
    {
      name  = "controller.serviceAccount.name"
      value = "efs-csi-controller-sa"
    }
  ]
}

################################################################################
# Kubernetes StorageClass
################################################################################

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"

    fileSystemId = aws_efs_file_system.django.id

    directoryPerms = "755"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  depends_on = [
    helm_release.efs_csi
  ]
}


################################################################################
# Outputs
################################################################################

output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.django.id
}

output "efs_file_system_arn" {
  description = "EFS file system ARN"
  value       = aws_efs_file_system.django.arn
}

output "efs_security_group_id" {
  description = "EFS security group ID"
  value       = aws_security_group.efs.id
}

output "efs_csi_iam_role_arn" {
  description = "IAM role ARN used by EFS CSI Driver"
  value       = aws_iam_role.efs_csi.arn
}

output "efs_csi_pod_identity_association_arn" {
  description = "EKS Pod Identity association ARN for EFS CSI Driver"
  value       = aws_eks_pod_identity_association.efs_csi.association_arn
}

output "efs_storage_class_name" {
  description = "Kubernetes EFS StorageClass name"
  value       = kubernetes_storage_class_v1.efs.metadata[0].name
}
