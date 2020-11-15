provider "aws" {
  region = "ap-northeast-1"
}

# 1. create VPC
module "vpc" {
  source = "../../network/vpc"
  name = "basic"
}

# 2. create internet gateway
module "ig" {
  source = "../../network/internetgateway"
  vpc = {
    id = module.vpc.vpc_id
    name = module.vpc.vpc_name
  }
}

# 3. create one pair of pub/priv subnets
module "create_and_connet_pub_priv_subnets0" {
  source = "../../network/combine__create_and_connect_private_public_subnets"
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
module "create_and_connet_pub_priv_subnets1" {
  source = "../../network/combine__create_and_connect_private_public_subnets"
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


/*********************************
* Bootup Instances
**********************************/
module "bastion" {
  source = "../../ec2module/bastion_server"
  name = "bastion"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.create_and_connet_pub_priv_subnets0.public_subnet_id
}

module "nginx" {
  source = "../../ec2module/web_server"
  name = "nginx"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  # intentionally pointing different subnet(for testing purpose)
  subnet_id = module.create_and_connet_pub_priv_subnets1.public_subnet_id
}

# TODO: move these part into web_server module
module "eip_for_nginx" {
  source = "../../network/elasticip"
  name = "eip_for_nginx"
}

resource "aws_eip_association" "eip_for_nginx" {
  instance_id = module.nginx.instance_id
  allocation_id = module.eip_for_nginx.eip_id
}

module "private_machine" {
  source = "../../ec2module/web_server"
  name = "private_machine"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_id
  # intentionally pointing different subnet(for testing purpose)
  subnet_id = module.create_and_connet_pub_priv_subnets1.private_subnet_id
}

/*********************************
* Bootup Datastore
**********************************/
// 1. RDB

// 2. Redis

// 3. SSM