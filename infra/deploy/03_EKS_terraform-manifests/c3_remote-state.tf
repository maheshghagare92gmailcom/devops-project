# --------------------------------------------------------------------
# Reference the Remote State from VPC Project
# --------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket               = "devops-recipe-app-tf-state-mahesh-new"
    key                  = "tf-state-vpc"
    region               = "us-east-1"
    workspace_key_prefix = "terraform-vpc"

    
  }

  workspace = terraform.workspace
}

# --------------------------------------------------------------------
# Output the VPC ID from the remote VPC state
# --------------------------------------------------------------------
output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

# --------------------------------------------------------------------
# Output the list of private subnets from the VPC
# --------------------------------------------------------------------
output "private_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}


# --------------------------------------------------------------------
# Output the list of public subnets from the VPC
# --------------------------------------------------------------------
output "public_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}

output "debug_remote_state_full" {
  value = data.terraform_remote_state.vpc
}
