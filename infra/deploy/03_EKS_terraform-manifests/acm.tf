################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "app" {
  domain_name       = "maheshdevops.shop"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.maheshdevops.shop"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "maheshdevops.shop"
    Environment = var.environment_name
  }
}


################################################################################
# ACM DNS Validation Record
################################################################################

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60

  records = [
    each.value.record
  ]
}


################################################################################
# ACM Certificate Validation
################################################################################

resource "aws_acm_certificate_validation" "app" {
  certificate_arn = aws_acm_certificate.app.arn

  validation_record_fqdns = [
    for record in aws_route53_record.acm_validation :
    record.fqdn
  ]
}


################################################################################
# Outputs
################################################################################

output "acm_certificate_arn" {
  description = "ACM certificate ARN for maheshdevops.shop"
  value       = aws_acm_certificate.app.arn
}

output "acm_certificate_status" {
  description = "ACM certificate status"
  value       = aws_acm_certificate.app.status
}
