/*
receive private subnet and public subnet.
connect them by routing via NAT
*/

variable "vpc" {
  type = object({id: string, name: string})
}
variable "ig" {
  type = object({raw_object: any, id: string})
}
variable "availability_zone" {}

variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}

# create public subnet
module "public_subnet" {
  source = "../publicsubnet"
  vpc = var.vpc
  ig = var.ig
  availability_zone = var.availability_zone
  cidr_block = var.public_subnet_cidr_block
}

# create private subnet
module "private_subnet" {
  source = "../privatesubnet"
  vpc = var.vpc
  ig = var.ig
  availability_zone = var.availability_zone
  cidr_block = var.private_subnet_cidr_block
}

# connect private subnet with nat
module "combine_private_public_subnet" {
  source = "../combine__private_public_subnets"
  public_subnet = {
    id = module.public_subnet.public_subnet_id
    name = module.public_subnet.public_subnet_name
  }
  private_subnet = {
    id = module.private_subnet.private_subnet_id
    name = module.private_subnet.private_subnet_name
  }
  vpc = var.vpc
}


output "nat_gateway_id" {
  value = module.combine_private_public_subnet.nat_gateway_id
}
output "public_subnet_id" {
  value = module.public_subnet.public_subnet_id
}
output "public_subnet_name" {
  value = module.public_subnet.public_subnet_name
}
output "private_subnet_id" {
  value = module.private_subnet.private_subnet_id
}
output "private_subnet_name" {
  value = module.private_subnet.private_subnet_name
}