/*
NOTE: this module CANNOT be used as it is! please replace
*/

variable "domain_name" {}

resource "aws_route53_zone" "default" {
  name = var.domain_name
}

output "route53_hostzone_id" {
  value = aws_route53_zone.default.id
}

output "route53_hostzone_zone_id" {
  value = aws_route53_zone.default.zone_id
}

output "route53_hostzone_name" {
  value = aws_route53_zone.default.name
}

