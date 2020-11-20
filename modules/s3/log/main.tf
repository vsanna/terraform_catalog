variable "name" {
  type = string
  description = "bucket name"
}


# Log Bucket
resource "aws_s3_bucket" "default" {
  bucket = "log--${var.name}"
  //  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

// an IAM policy which allows a subject to do putObject to target bucket
# in this case, attach target is AWS account satisfying AWS(id=470260006854)
data "aws_iam_policy_document" "alb_log_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arm:aws:s3:::${aws_s3_bucket.default.id}/*"]

    principals {
      # AWS account itself
      type = "AWS"
      identifiers = ["470260006854"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.alb_log_iam_policy_document.json
}

output "bucket_id" {
  value = aws_s3_bucket.default.id
}

output "bucket_arn" {
  value = aws_s3_bucket.default.arn
}
