variable "name" {}


resource "aws_ecs_cluster" "default" {
  name = var.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.default.arn
}