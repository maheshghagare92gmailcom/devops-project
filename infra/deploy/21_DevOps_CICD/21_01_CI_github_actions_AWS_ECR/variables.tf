variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "github_repo" {
  description = "GitHub repo in format owner/repo"
  type        = string
  default     = "maheshghagare92gmailcom/aws-django-eks-tutorial_image_receipe_app_api-final"
}

variable "role_name" {
  description = "IAM Role name for GitHub Actions"
  default     = "github-actions-oidc-role-ui3"
}
