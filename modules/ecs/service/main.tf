variable "name" {}
variable "cluster_arn" {}
variable "task_arn" {}
variable "vpc_id" {}
variable "target_group_arn" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}

resource "aws_ecs_service" "default" {
  name = var.name
  cluster = var.cluster_arn
  task_definition = var.task_arn
  desired_count = 3
  launch_type = "FARGATE"
  platform_version = "1.3.0"
  // seconds to wait for the first healthcheck
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [module.nginx.security_group_id]
    subnets = [var.public_subnet_id, var.private_subnet_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = "example"
    container_port = 80
  }
}

module "nginx" {
  source = "../../securitygroup"
  name = "nginx-sg"
  vpc_id = var.vpc_id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}