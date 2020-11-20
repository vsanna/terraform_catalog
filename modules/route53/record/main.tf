/*
NOTE: this module CANNOT be used as it is! please replace
*/

variable "record_type" {}

variable "alb_dns_zone_id" {}
variable "alb_dns_name" {}
variable "route53hostzone_zone_id" {}
variable "route53hostzone_name" {}

resource "aws_route53_record" "default" {
  zone_id = var.route53hostzone_zone_id
  name = var.route53hostzone_name
  type = var.record_type

  // if type == "A"(which means "ALIAS"), alb does foward requests to this target.
  alias {
    name = var.alb_dns_name
    zone_id = var.alb_dns_zone_id
    evaluate_target_health = true
  }
}
