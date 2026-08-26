terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  backend "s3" {
    bucket               = "devops-recipe-app-tf-state-mahesh-new"
    key                  = "tf-state-vpc"
    workspace_key_prefix = "terraform-vpc"
    region               = "us-east-1"
    encrypt              = true
    dynamodb_table       = "devops-recipe-app-tf-state-lock-mahesh"
  }
}

provider "aws" {
  region = var.aws_region
}
