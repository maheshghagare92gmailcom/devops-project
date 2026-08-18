# resource "aws_vpc_security_group_ingress_rule" "eks_from_alb_1" {
#   security_group_id            = "sg-013c8e714af007bc8"
#   referenced_security_group_id = "sg-0464636ed0557fef7"

#   ip_protocol = "tcp"
#   from_port   = 8000
#   to_port     = 8000

#   description = "Allow ALB SG 1 to reach EKS nodes on TCP 8000"
# }

# resource "aws_vpc_security_group_ingress_rule" "eks_from_alb_2" {
#   security_group_id            = "sg-013c8e714af007bc8"
#   referenced_security_group_id = "sg-0e3f0f03581a83a71"

#   ip_protocol = "tcp"
#   from_port   = 8000
#   to_port     = 8000

#   description = "Allow ALB SG 2 to reach EKS nodes on TCP 8000"
# }
