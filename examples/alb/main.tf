terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/alb"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "alb" {
  source = "../../modules/alb"
  name = "test"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.create_and_connet_pub_priv_subnets0.public_subnet_id,
    module.create_and_connet_pub_priv_subnets0.private_subnet_id
  ]
}

# 1. create vpc
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
