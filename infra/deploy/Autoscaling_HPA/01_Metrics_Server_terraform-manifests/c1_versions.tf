terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.20"
    }
  }

  # Remote backend configuration using S3 
  backend "s3" {
    bucket         = "devops-recipe-app-tf-state-mahesh"
    key            = "hpa_autoscaling"
    # workspace_key_prefix = "tf-state-deploy-env"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-recipe-app-tf-state-lock-mahesh"
  }
}
  provider "aws" {
  # AWS region to use for all resources (from variables)
  region = var.aws_region
} 
