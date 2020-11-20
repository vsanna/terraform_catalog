variable "description" {}

resource "aws_kms_key" "default" {
  description = var.description
  enable_key_rotation = true
  is_enabled = true
  // how many days kms keeps this key after calling deletion operation
  deletion_window_in_days = 30
}

output "key_id" {
  value = aws_kms_key.default.id
}

output "key_arn" {
  value = aws_kms_key.default.arn
}