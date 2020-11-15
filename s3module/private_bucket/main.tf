variable "name" {
  type = string
  description = "bucket name"
}

# Private bucket
resource "aws_s3_bucket" "default" {
  bucket = "private--${var.name}"

  versioning {
    enabled = true
  }

  # ほぼデメリット無しなので使う
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


output "bucket_id" {
  value = aws_s3_bucket.default.id
}

output "bucket_arn" {
  value = aws_s3_bucket.default.arn
}
