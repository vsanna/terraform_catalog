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

# s3の対象bucketに対しputObjectすることができる、というIAMポリシー
# attach対象はAWS(id=470260006854)を満たすもの
data "aws_iam_policy_document" "alb_log_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arm:aws:s3:::${aws_s3_bucket.default.id}/*"]

    principals {
      # AWS アカウントそのもの
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
