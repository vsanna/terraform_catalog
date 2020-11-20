terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/route53"
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

# 4. create route53 hostzone
module "route53" {
  source = "../../modules/route53/hostzone"
  domain_name = "example.com"
}

# 5. create route53 alias record
module "route53record" {
  source = "../../modules/route53/record"
  record_type = "A"
  alb_dns_name = module.alb.alb_dns_name
  alb_dns_zone_id = module.alb.alb_zone_id
  route53hostzone_name = module.route53.route53_hostzone_name
  route53hostzone_zone_id = module.route53.route53_hostzone_zone_id
}