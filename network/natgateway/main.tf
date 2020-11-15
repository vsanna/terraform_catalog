variable "vpc" {
  type = object({id: string, name: string})
}

variable "public_subnet" {
  type = object({id: string, name: string})
}


/*
NAT Gateway
- an object which provides NAT function
- dynamic NAT
  - private subnet内のEC2インスタンスのprivateIPとpublicIPをN:1で変換する
  - privateIp + portと、行き先IPの対応表を格納する
  - こちらから外に出て戻ってくることはできても、外から始まるリクエストはできない
- attached to "subnet"!
- このNATgateway自身ののprivate/publicIPの対応はIGに収められている
- ElasticIP必要
*/
resource "aws_nat_gateway" "default" {
  allocation_id = module.nat_eip.eip_id
  subnet_id = var.public_subnet.id

  tags = {
    Name = "nat:(${var.public_subnet.name})"
  }
}

module "nat_eip" {
  source = "../elasticip"
  # To avoid cyclic dependencies.
  name = "for_nat(nat:${var.public_subnet.name})"
}

output "nat_id" {
  value = aws_nat_gateway.default.id
}
