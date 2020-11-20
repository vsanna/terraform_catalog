variable "vpc" {
  type = object({id: string, name: string})
}

/*
Internet Gateway
- an object which provides NAT function between VPC and the Internet
- static NAT
  - translate privateIPs in public subnet with 1:1 relationship
  - when a ec2 starts, IG collects information about an entiry: {privateIP, publicIP}
- attached to VPC
- example traffic flow
  1. from private subnet
    - EC2 in private subnet -> NAT gateway in public subnet -> IG -> outside
    - public subnet's default routing entry points to IG
  2. from public subnet
    - EC2 in public subjet -> IG -> outside
*/
resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc.id

  tags = {
    Name = "ig:(${var.vpc.name})"
  }
}

output "ig_id" {
  value = aws_internet_gateway.default.id
}

output "ig_raw_object" {
  value = aws_internet_gateway.default
}
