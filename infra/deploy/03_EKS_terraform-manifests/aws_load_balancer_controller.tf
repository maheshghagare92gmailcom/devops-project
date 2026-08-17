################################################################################
# AWS Load Balancer Controller
# EKS Pod Identity
################################################################################

locals {
  aws_load_balancer_controller_namespace = "kube-system"
  aws_load_balancer_controller_sa        = "aws-load-balancer-controller"
  aws_load_balancer_controller_role      = "${local.name}-aws-lb-controller"
}


################################################################################
# AWS Load Balancer Controller IAM Policy
################################################################################

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${local.name}-AWSLoadBalancerControllerPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ------------------------------------------------------------------------
      # Service Linked Role
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "iam:CreateServiceLinkedRole"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },

      # ------------------------------------------------------------------------
      # EC2 Describe Permissions
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeManagedPrefixLists",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribePrefixLists",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:GetCoipPoolUsage",
          "ec2:GetSecurityGroupsForVpc",
          "ec2:GetManagedPrefixListEntries"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # ACM
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Cognito
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "cognito-idp:DescribeUserPoolClient"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # WAF
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Shield
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Security Groups
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "ec2:CreateSecurityGroup"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateTags"
        ]

        Resource = "arn:aws:ec2:*:*:security-group/*"

        Condition = {
          StringEquals = {
            "ec2:CreateAction" = "CreateSecurityGroup"
          }

          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]

        Resource = "arn:aws:ec2:*:*:security-group/*"

        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ]

        Resource = "*"

        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      # ------------------------------------------------------------------------
      # Elastic Load Balancing - Describe
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DescribeAccountLimits",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Create Load Balancer / Target Groups / Listeners
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:ModifyListener"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Tagging ELB Resources
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
  ]

  Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:RemoveTags"
        ]

        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
      },

      # ------------------------------------------------------------------------
      # Delete ELB Resources
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteRule"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------------------------
      # Target Registration
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]

        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },

      # ------------------------------------------------------------------------
      # Modify Target Groups
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes"
        ]

        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },

      # ------------------------------------------------------------------------
      # Modify Load Balancer Security Groups
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:SetSecurityGroups"
        ]

        Resource = [
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
      },

      # ------------------------------------------------------------------------
      # Listener / Rule Modification
      # ------------------------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule"
        ]

        Resource = "*"
      }
    ]
  })
}


################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = local.aws_load_balancer_controller_role

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
    Name        = local.aws_load_balancer_controller_role
    Environment = var.environment_name
  }
}


################################################################################
# Attach IAM Policy to Role
################################################################################

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}


################################################################################
# EKS Pod Identity Association
################################################################################

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = local.aws_load_balancer_controller_namespace
  service_account = local.aws_load_balancer_controller_sa
  role_arn        = aws_iam_role.aws_load_balancer_controller.arn
}


################################################################################
# Helm Repository
################################################################################

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace        = local.aws_load_balancer_controller_namespace
  create_namespace = false

  # Pin a known chart version rather than using an uncontrolled latest.
  version = "1.13.4"

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.main.name

      region = "us-east-1"

      vpcId = data.terraform_remote_state.vpc.outputs.vpc_id

      serviceAccount = {
        create = true
        name   = local.aws_load_balancer_controller_sa
      }
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}
