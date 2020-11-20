variable "name" {}
variable "subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}


resource "aws_alb" "default" {
  name = var.name
  load_balancer_type = "application"

  # internal: receive requests only from internal vpc
  #
  internal = false
  idle_timeout = 50
  enable_deletion_protection = true

  # alb forwards traffics to specified availability zones
  # one az can have 1 subnet
  subnets = var.subnet_ids

  access_logs {
    bucket = module.aws_log.bucket_id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.default.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "this is http!!"
      status_code = "200"
    }
  }
}

module "aws_log" {
  source = "../../modules/s3/log"
  name = var.name
}

module "http_sg" {
  source = "../../modules/securitygroup"
  name = "http_alb_for_${var.name}"
  port = "80"
  cidr_blocks = ["0.0.0.0/0"]
  vpc_id = var.vpc_id
}

module "https_sg" {
  source = "../../modules/securitygroup"
  name = "https_alb_for_${var.name}"
  port = "443"
  cidr_blocks = ["0.0.0.0/0"]
  vpc_id = var.vpc_id
}

module "http_redirect_sg" {
  source = "../../modules/securitygroup"
  name = "http_redirect_alb_for_${var.name}"
  port = "8080"
  cidr_blocks = ["0.0.0.0/0"]
  vpc_id = var.vpc_id
}

output "alb_dns_name" {
  value = aws_alb.default.dns_name
}

output "alb_id" {
  value = aws_alb.default.id
}

output "alb_zone_id" {
  value = aws_alb.default.zone_id
}