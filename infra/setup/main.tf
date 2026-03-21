terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }

  backend "s3" {
    bucket         = "devops-recipe-app-tf-state-12499421"
    key            = "tf-state-setup"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-recipe-app-tf-state-12499421"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = var.project
      Contact     = var.contact
      ManageBy    = "Terraform/setup"
    }
  }
}


# resource "aws_iam_service_linked_role" "rds" {
#   aws_service_name = "rds.amazonaws.com"
# }

# resource "aws_iam_service_linked_role" "elb" {
#   aws_service_name = "elasticloadbalancing.amazonaws.com"
# }

# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }
