terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }


  # Remote Backend
  
  backend "s3" {
    bucket         = "devops-recipe-app-tf-state-mahesh"
    key            = "tf-state-deploy"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-recipe-app-tf-state-lock-mahesh"
  }

}



