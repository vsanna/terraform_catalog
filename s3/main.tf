provider "aws" {
  region = "ap-northeast-1"
}

# Private bucket
resource "aws_s3_bucket" "private_example" {
  bucket = "private-bucket-example"
//  force_destroy = true

  # 変更/削除時に元に戻せる. true運用が基本
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

resource "aws_s3_bucket_public_access_block" "private_access" {
  bucket = aws_s3_bucket.private_example.id

  # ACL: Access Control List
  # bucket/objectへのアクセス管理。各bucket/objectにはサブリソースとして個別にACLがアタッチされている
  # public acl = aclない主体のこと?
  # アクセスポイントを介したリクエストに対しては、Amazon S3 は、アクセスポイントのブロックパブリックアクセス設定もチェックします。

  # (Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to false. Enabling this setting does not affect existing policies or ACLs. When set to true causes the following behavior:
  block_public_acls = true

  # (Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the existing bucket policy.
  block_public_policy = true

  # (Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to false. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set.
  ignore_public_acls = true

  # (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked.
  restrict_public_buckets = true
}


# Public bucket
resource "aws_s3_bucket" "public_example" {
  bucket = "public-bucket-example"
//  force_destroy = true
  # (Optional) The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write
  # canned ACL = 規定ACL. 予め非付与者とアクセス許可内容のセットを定義したもの.
  # private: 所有者がFULL_CONTROL
  # public: 所有者がFULL_CONTROL, AllUserにREAD, などなど
  #
  # 個別のuserにだけgrantでアクセス許可を与えることもできる
  acl = "public-read"

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
    allowed_methods = ["GET"]
    allowed_origins = ["http://localhost"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}


# Log Bucket
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-example"
//  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

data "aws_iam_policy_document" "alb_log_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arm:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      # AWS アカウントそのもの
      type = "AWS"
      identifiers = ["470260006854"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log_iam_policy_document.json
}

