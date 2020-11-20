variable "vpc" {
  type = object({
    id: string, name: string
  })
}
variable "ig" {
  type = object({
    id: string
  })
}
variable "availability_zone" {
  default = "ap-northeast-1a"
}

variable "cidr_block" {}

resource "aws_subnet" "private_default" {
  vpc_id = var.vpc.id
  cidr_block = var.cidr_block #"10.0.64.0/24"
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet:(${var.vpc.name}-${var.availability_zone})"
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = var.vpc.id
  tags = {
    Name = "route_table:(${aws_subnet.private_default.tags["Name"]}"
  }
}

// as routing needs mapping between nat/public subnet, so here we don't create routing table
// TODO: use depends_on
//resource "aws_route" "private_subnet_default_route" {}

resource "aws_route_table_association" "private_table_association" {
  route_table_id = aws_route_table.private_subnet_route_table.id
  subnet_id = aws_subnet.private_default.id
}

output "private_subnet_id" {
  value = aws_subnet.private_default.id
}
output "private_subnet_name" {
  value = aws_subnet.private_default.tags["Name"]
}
