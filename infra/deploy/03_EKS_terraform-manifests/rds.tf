################################################################################
# Existing AWS Secrets Manager Secret
################################################################################
# The secret "django-db-secret" was created manually in AWS Secrets Manager.
#
# Terraform only READS this existing secret.
# Terraform does NOT create or modify the secret.
################################################################################

data "aws_secretsmanager_secret" "django_db" {
  name = "django-db-secret"
}

data "aws_secretsmanager_secret_version" "django_db" {
  secret_id = data.aws_secretsmanager_secret.django_db.id
}


################################################################################
# Decode Secret JSON
################################################################################

locals {
  django_db_secret = try(
    jsondecode(
      data.aws_secretsmanager_secret_version.django_db.secret_string
    ),
    {}
  )
}


################################################################################
# TEMPORARY DEBUG OUTPUTS
################################################################################
# These are only for validating that Terraform can read the existing
# AWS Secrets Manager secret.
#
# They are marked sensitive = true.
#
# Remove these outputs after testing.
################################################################################

output "debug_django_db_name" {
  description = "Temporary debug: DB name from AWS Secrets Manager"
  value       = local.django_db_secret.DB_NAME
  sensitive   = true
}

output "debug_django_db_user" {
  description = "Temporary debug: DB username from AWS Secrets Manager"
  value       = local.django_db_secret.DB_USER
  sensitive   = true
}

output "debug_django_db_password" {
  description = "Temporary debug: DB password from AWS Secrets Manager"
  value       = local.django_db_secret.DB_PASS
  sensitive   = true
}


################################################################################
# RDS PostgreSQL Security Group
################################################################################

resource "aws_security_group" "rds_postgres_sg" {
  name        = "${local.name}-rds-postgres-sg"
  description = "Allow PostgreSQL access from EKS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow PostgreSQL from EKS cluster"
    from_port   = 5432
    to_port     = 5432
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
    Name = "${local.name}-rds-postgres-sg"
  }
}


################################################################################
# RDS DB Subnet Group
################################################################################
# Uses the private subnets created by your VPC Terraform project.
################################################################################

resource "aws_db_subnet_group" "rds_private" {
  name = "${local.name}-rds-private-subnets"

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "${local.name}-rds-private-subnets"
  }
}


################################################################################
# RDS PostgreSQL Instance
################################################################################

resource "aws_db_instance" "django_postgres" {
  identifier = "mydb3"

  engine         = "postgres"
  engine_version = "15"

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  # Database configuration comes from the existing
  # AWS Secrets Manager secret.
  db_name  = local.django_db_secret.DB_NAME
  username = local.django_db_secret.DB_USER
  password = local.django_db_secret.DB_PASS

  port = 5432

  # Private subnet group
  db_subnet_group_name = aws_db_subnet_group.rds_private.name

  # RDS security group
  vpc_security_group_ids = [
    aws_security_group.rds_postgres_sg.id
  ]

  # RDS should NOT be publicly accessible
  publicly_accessible = false

  # Single-AZ for this project/lab
  multi_az = false

  # Backup configuration
  backup_retention_period  = 1
  delete_automated_backups = true

  # Convenient for a development/project environment
  skip_final_snapshot = true

  tags = {
    Name = "${local.name}-django-postgres"
  }
}


################################################################################
# RDS Outputs
################################################################################

output "django_postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.django_postgres.address
}

output "django_postgres_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.django_postgres.port
}

output "django_postgres_database_name" {
  description = "PostgreSQL database name"
  value       = aws_db_instance.django_postgres.db_name
  sensitive = true
}

output "django_postgres_username" {
  description = "PostgreSQL username"
  value       = aws_db_instance.django_postgres.username
  sensitive   = true
}

output "django_postgres_sg_id" {
  description = "RDS PostgreSQL security group ID"
  value       = aws_security_group.rds_postgres_sg.id
}
