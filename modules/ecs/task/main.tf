variable "name" {}
variable "iam_role_arn" {}

resource "aws_ecs_task_definition" "default" {
  family = var.name
  cpu = "256"
  memory = "512"

  // for fargate
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  // TODO: replace here with variable
  container_definitions = file("./container_definitions.json")

  execution_role_arn = var.iam_role_arn
}

output "task_arn" {
  value = aws_ecs_task_definition.default.arn
}