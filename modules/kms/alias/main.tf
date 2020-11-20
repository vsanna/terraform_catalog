variable "name" {}
variable "key_id" {}

resource "aws_kms_alias" "default" {
  name = "alias/${name}"
  target_key_id = var.key_id
}

output "alias_id" {
  value = aws_kms_alias.default.id
}