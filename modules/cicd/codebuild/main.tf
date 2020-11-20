/*
CodeBuild is a step of CodePipeline, where build job runs
*/

variable "name" {}

resource "aws_codebuild_project" "default" {
  name = var.name
  service_role = module.codebuild_role.iam_role_arn

  // both input and output are working with CodePipeline
  source {
    type = "CODEPIPELINE"
  }
  artifacts {
    type = "CODEPIPELINE"
  }

  // environment for build jobs.
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:2.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",

      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
  }
}

module "codebuild_role" {
  source = "../../iamrole"
  name = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy = data.aws_iam_policy_document.codebuild.json
}




data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",

      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
  }
}
