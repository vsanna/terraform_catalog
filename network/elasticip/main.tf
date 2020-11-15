variable "name" {}

resource "aws_eip" "default" {
  vpc = true

  # depends_on = このリソースを先に用意しておいてくれ、の意
  # このリソースと何かしらの関連付けをするわけではない
  # 追記: depends_onは同一moduleないでないと使えない...
//  depends_on = [var.ig.raw_object]

  tags = {
    Name = "eip:(${var.name})"
  }
}

output "eip_id" {
  value = aws_eip.default.id
}
output "eip_ip" {
  value = aws_eip.default.public_ip
}
output "eip_dns" {
  value = aws_eip.default.public_dns
}

