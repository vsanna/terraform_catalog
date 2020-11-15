variable "vpc" {
  type = object({id: string, name: string})
}
variable "ig" {
  type = object({id: string})
}
variable "availability_zone" {
  default = "ap-northeast-1a"
}

variable "cidr_block" {}

resource "aws_subnet" "public_default" {
  vpc_id = var.vpc.id
  cidr_block = var.cidr_block #"10.0.0.0/24"
  availability_zone = var.availability_zone
  # このsubnetで起動したインスタンスに自動でpublicIPを割り振ってくれる(変動する)
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet:(${var.vpc.name}-${var.availability_zone})"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = var.vpc.id
  tags = {
    Name = "route_table:(${aws_subnet.public_default.tags["Name"]})"
  }
}

# 他のどのrouteにもマッチしない場合は外向きと捉えてigにrouting
resource "aws_route" "public_subnet_default_route" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  gateway_id = var.ig.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_table_association" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id = aws_subnet.public_default.id
}

output "public_subnet_id" {
  value = aws_subnet.public_default.id
}
output "public_subnet_name" {
  value = aws_subnet.public_default.tags["Name"]
}
