variable "domain_name" {}

resource "aws_acm_certificate" "default" {
  domain_name = var.domain_name
  subject_alternative_names = []
  validation_method = "DNS"

  # destroy existing certification AFTER creating new one
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "verification_record" {
  name = aws_acm_certificate.default.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.default.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.default.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.target_hostzone.id
  ttl = 60
}

data "aws_route53_zone" "target_hostzone" {
  name = var.domain_name
}

output "acm_id" {
  value = aws_acm_certificate.default.id
}