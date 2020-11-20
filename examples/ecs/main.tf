terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/ecs"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# 1. create VPC
module "vpc" {
  source = "../../modules/network/vpc"
  name = "pet"
}

# 2. create internet gateway
module "ig" {
  source = "../../modules/network/internetgateway"
  vpc = {
    id = module.vpc.vpc_id
    name = module.vpc.vpc_name
  }
}

# 3. create one pair of pub/priv subnets
module "create_and_connet_pub_priv_subnets0" {
  source = "../../modules/network/combine__create_and_connect_private_public_subnets"
  vpc = {
    id = module.vpc.vpc_id
    name = module.vpc.vpc_name
  }
  ig = {
    raw_object = module.ig.ig_raw_object
    id = module.ig.ig_id
  }
  availability_zone = "ap-northeast-1a"
  public_subnet_cidr_block = "10.0.0.0/24"
  private_subnet_cidr_block = "10.0.1.0/24"
}

# 4. create alb
module "alb" {
  source = "../../modules/alb"
  name = "ecs"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.create_and_connet_pub_priv_subnets0.private_subnet_id,
    module.create_and_connet_pub_priv_subnets0.public_subnet_id
  ]
}

module "alb_target_group" {
  source = "../../modules/alb/target_group"
  name = "ecs_task"
  vpc_id = module.vpc.vpc_id
  health_check_path = "/"
}

module "cluster" {
  source = "../../modules/ecs/cluster"
  name = "example"
}

module "task" {
  source = "../../modules/ecs/task"
  name = "example"
  iam_role_arn = module.ecs_task_execution_role.iam_role_arn
}

module "service" {
  source = "../../modules/ecs/service"
  name = "example"

  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.create_and_connet_pub_priv_subnets0.public_subnet_id
  private_subnet_id = module.create_and_connet_pub_priv_subnets0.private_subnet_id

  target_group_arn = module.alb_target_group.target_troup_arn

  cluster_arn = module.cluster.cluster_arn
  task_arn = module.task.task_arn
}

resource "aws_cloudwatch_log_group" "ecs_log" {
  name = "/ecs/example"
  retention_in_days = 30
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam:aws:policy/service-role/AmazonECSTaskExecutionRole"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy
  statement {
    effect = "Allow"
    actions = ["ssm:GetParameter", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source = "../../modules/iamrole"
  name = "ecs-task-execution"
  identifier = "ecs-tasks"
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}


