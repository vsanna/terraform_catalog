variable "name" {}
variable "vpc_id" {}
variable "health_check_path" {
  default = "/health"
}

resource "aws_alb_target_group" "default" {
  name = var.name
  target_type = "ip"
  vpc_id = var.vpc_id
  port = 80
  protocol = "HTTP"
  deregistration_delay = 300

  health_check {
    path = var.health_check_path
    // trial count to consider it recovers
    healthy_threshold = 5
    // trial count to consider it is dead
    unhealthy_threshold = 2

    timeout = 5
    interval = 30
    // 200 is success
    matcher = 200
    // use port defined above
    port = "traffic-port"
    protocol = "HTTP"
  }
}

output "target_troup_arn" {
  value = aws_alb_target_group.default.arn
}