
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    # Allow GitHub Actions only from this repository
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:maheshghagare92gmailcom@142685349/devops-project@1330623138:ref:refs/heads/*"
      ]
    }

    # Ensure the token is intended for AWS STS
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json

  tags = {
    Name        = "github-actions-oidc-role"
    ManagedBy   = "Terraform"
    Project     = "devops-project"
    Environment = "dev"
  }
}

# Allow GitHub Actions to push Docker images to ECR
resource "aws_iam_role_policy_attachment" "github_ecr_access" {
  role = aws_iam_role.github_actions_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "github_admin_access" {
  role = aws_iam_role.github_actions_role.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


output "github_actions_role_arn" {
  description = "IAM role ARN used by GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}

