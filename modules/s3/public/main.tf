variable "name" {
  type = string
  description = "bucket name"
}

variable "acl" {
  type = string
  description = "acl for the bucket. (private|public-read|public-read-write|aws-exec-read|authenticated-read|log-delivery-write)"
//  validation {}
}

variable "cors_allowed_methods" {
  type = list(string)
  default = ["GET"]
}

variable "cors_allowed_origins" {
  type = list(string)
  default = ["http://localhost"]
}

variable "cors_allowed_headers" {
  type = list(string)
  default = ["*"]
}

# Public bucket
resource "aws_s3_bucket" "default" {
  bucket = "public--${var.name}"
  acl = var.acl

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  cors_rule {
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    allowed_headers = var.cors_allowed_headers
    max_age_seconds = 3000
  }
}

output "bucket_id" {
  value = aws_s3_bucket.default.id
}

output "bucket_arn" {
  value = aws_s3_bucket.default.arn
}
