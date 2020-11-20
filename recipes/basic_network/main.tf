terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "recipes/basic_network"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}


# 1. create VPC
module "vpc" {
  source = "..\/..\/modules\/network/vpc"
  name = "basic"
}

# 2. create internet gateway
module "ig" {
  source = "..\/..\/modules\/network/internetgateway"
  vpc = {
    id = module.vpc.vpc_id
    name = module.vpc.vpc_name
  }
}

# 3. create one pair of pub/priv subnets
module "create_and_connet_pub_priv_subnets0" {
  source = "..\/..\/modules\/network/combine__create_and_connect_private_public_subnets"
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

# 3-2. create one more pair
module "create_and_connect_pub_priv_subnets1" {
  source = "..\/..\/modules\/network/combine__create_and_connect_private_public_subnets"
  vpc = {
    id = module.vpc.vpc_id
    name = module.vpc.vpc_name
  }
  ig = {
    raw_object = module.ig.ig_raw_object
    id = module.ig.ig_id
  }
  availability_zone = "ap-northeast-1c"
  public_subnet_cidr_block = "10.0.2.0/24"
  private_subnet_cidr_block = "10.0.3.0/24"
}


# ================================
# to test this configurations, starting small 2 ec2 instances for each pub/priv subnet
# ================================
module "bastion" {
  source = "..\/..\/ec2/bastion_server"
  name = "bastion"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.create_and_connet_pub_priv_subnets0.public_subnet_id
}

module "nginx" {
  source = "..\/..\/ec2/web_server"
  name = "nginx"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  # intentionally pointing different subnet(for testing purpose)
  subnet_id = module.create_and_connect_pub_priv_subnets1.public_subnet_id
}

# TODO: move these part into web_server module
module "eip_for_nginx" {
  source = "..\/..\/modules\/network/elasticip"
  name = "eip_for_nginx"
}

resource "aws_eip_association" "eip_for_nginx" {
  instance_id = module.nginx.instance_id
  allocation_id = module.eip_for_nginx.eip_id
}

module "private_machine" {
  source = "..\/..\/ec2/web_server"
  name = "private_machine"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  # intentionally pointing different subnet(for testing purpose)
  subnet_id = module.create_and_connect_pub_priv_subnets1.private_subnet_id
}
