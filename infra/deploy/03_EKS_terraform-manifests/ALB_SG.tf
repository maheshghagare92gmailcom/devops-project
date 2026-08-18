################################################################################
# ALB Security Group
################################################################################

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Security group for Kubernetes ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-alb-sg"
  })
}


################################################################################
# ALB - HTTP Ingress
################################################################################

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow HTTP to ALB"
}


################################################################################
# ALB - HTTPS Ingress
################################################################################

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow HTTPS to ALB"
}


################################################################################
# ALB - Egress
#
# Required so the internet-facing ALB can initiate connections to
# Kubernetes pod targets, including TCP 8000 health checks.
################################################################################

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow ALB outbound traffic"
}


################################################################################
# EKS Worker/Cluster Security Group
# Allow ALB to reach EKS targets on TCP 8000
################################################################################

resource "aws_vpc_security_group_ingress_rule" "eks_from_alb" {
  security_group_id = (
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  )

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 8000
  to_port     = 8000

  description = "Allow ALB to reach EKS nodes on TCP 8000"
}


output "alb_security_group_id" {
  description = "Security Group ID used by the AWS ALB"
  value       = aws_security_group.alb.id
}
