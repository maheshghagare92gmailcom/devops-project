# resource "aws_route53_zone" "main" {
#   name = "maheshdevops.shop"

#   lifecycle {
#     prevent_destroy = true
#   }

#   tags = {
#     Name        = "maheshdevops.shop"
#     Environment = var.environment_name
#   }
# }

# output "route53_nameservers" {
#   description = "Route 53 nameservers to configure at Hostinger"
#   value       = aws_route53_zone.main.name_servers
# }
################################################################################
# Existing Route 53 Hosted Zone
# Created manually in AWS
################################################################################

data "aws_route53_zone" "main" {
  name         = "maheshdevops.shop."
  private_zone = false
}
