variable "name" {}

resource "aws_eip" "default" {
  vpc = true

  # depends_on: this is not aws api but terraform's api.
  # if a resource has this field, it waits for those specifed resource to be created
  # note: depends_on can be used only with components in the same module...
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

