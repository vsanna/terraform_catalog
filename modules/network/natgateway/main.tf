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
  - translate privateIPS in private subnet with 1:N replationship
  - DNAT stores records like [from: {senderPrivateIP, port}, to: distIP]
  - requests can go out and come back from internal,
  - but any requests originated by outside world cannot reach to ec2 in private subnets
- attached to "subnet"!
- an entiry({privateIP, publicIP})} of this NAT itself is stored in IG
- NAT requires elasticIP
*/
resource "aws_nat_gateway" "default" {
  allocation_id = module.nat_eip.eip_id
  subnet_id = var.public_subnet.id

  tags = {
    Name = "nat:(${var.public_subnet.name})"
  }
}

module "nat_eip" {
  source = "../../../modules/network/elasticip"
  # To avoid cyclic dependencies.
  name = "for_nat(nat:${var.public_subnet.name})"
}

output "nat_id" {
  value = aws_nat_gateway.default.id
}
