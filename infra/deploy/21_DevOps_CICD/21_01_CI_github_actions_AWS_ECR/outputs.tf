output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.ui.repository_url
}

output "github_role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
