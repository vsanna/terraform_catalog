/*
receive private subnet and public subnet.
connect them by routing
*/

variable "private_subnet" {
  type = object({id: string, name: string})
}
variable "public_subnet" {
  type = object({id: string, name: string})
}
variable "vpc" {
  type = object({id: string, name: string})
}

// private subnetとpublic subnetをroutingで紐付ける
// ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table
data "aws_route_table" "private_subnet_route_table" {
  subnet_id = var.private_subnet.id
}

module "nat_gateway" {
  source = "../natgateway"
  vpc = var.vpc
  public_subnet = var.public_subnet
}

resource "aws_route" "private_subnet_default_route" {
  route_table_id = data.aws_route_table.private_subnet_route_table.id
  nat_gateway_id = module.nat_gateway.nat_id
  destination_cidr_block = "0.0.0.0/0"
}

output "nat_gateway_id" {
  value = module.nat_gateway.nat_id
}
