/*
NOTE: how to use ecr from local
1. setup auth
$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)

2. build
docker build -t xxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/myimage:latest .

3. push
docker push xxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/myimage:latest
*/
variable "name" {}

resource "aws_ecr_repository" "default" {
  name = var.name
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = file("./ecr_repository_policy.json")
}

output "ecr_id" {
  value = aws_ecr_repository.default.id
}
output "ecr_name" {
  value = aws_ecr_repository.default.name
}
output "ecr_arn" {
  value = aws_ecr_repository.default.arn
}
