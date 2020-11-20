/*
CodeBuild is a step of CodePipeline, where build job runs
*/

variable "name" {}
variable "github_orgname" {}
variable "github_reponame" {}
variable "codebuild_id" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}

provider "github" {
  organization = var.github_orgname
}

resource "aws_codepipeline" "default" {
  name = "codepipeline:(${var.name})"
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = 1
      output_artifacts = ["Source"]
      // webhook regarding any merge into master branch will trigger
      configuration = {
        Owner = var.github_orgname
        Repo = var.github_reponame
        Branch = "master"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = 1
      input_artifacts = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = var.codebuild_id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ECS"
      version = 1
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName = "imagedefinitions.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.default.id
    type = "S3"
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "artifact_${var.name}"
  lifecycle_rule {
    enabled = true
    expiration {
      days = 180
    }
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",

      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:PutLogEvents",

      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",

      "iam:PassRole"
    ]
  }
}

module "codepipeline_role" {
  source = "../../iamrole"
  name = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_codepipeline_webhook" "github" {
  name = "codepipeline_github_webhook:(${var.name})"
  authentication = "GITHUB_HMAC"

  target_pipeline = aws_codepipeline.default.name
  target_action = "Source"

  authentication_configuration {
    secret_token = "secret_key_should_not_be_stored_here..."
  }

  filter {
    json_path = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

// Configuration FOR GITHUB! github's webhook is also target to manage by terraform
resource "github_repository_webhook" "github_webhook" {
  events = ["push"]
  repository = var.github_reponame

  configuration {
    url = aws_codepipeline_webhook.github.url
    secret = "secret_key_should_not_be_stored_here"
    content_type = "json"
    insecure_ssl = false
  }
}