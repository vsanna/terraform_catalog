variable "name" {}


# https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-dns.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "default" {
  # いくつまで使えるんだ？
  # ピアリングも考慮してよく考える
  cidr_block = "10.0.0.0/16"
  # そもそもDNSを使うか否か
  enable_dns_support = true
  # publicIPを持つインスタンスが対応するpublicなhostnameを持つかどうか
  enable_dns_hostnames = true

  tags = {
    Name = "vpc:${var.name}"
  }
}

// NOTE: returning custom object or aws_vpc itself is possible.
// but IDE doesn't support type suggestion from outputs of modules.
// it looks that we it's not a good practice to pass object instead of primitive values..

//output "vpc" {
//  value = aws_vpc.default
//}

//output "vpc" {
//  type = object({id: string})
//  value = {
//    id = aws_vpc.default.id
//  }
//}

output "vpc_id" {
  value = aws_vpc.default.id
}
output "vpc_name" {
  value = aws_vpc.default.tags["Name"]
}
