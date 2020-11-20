terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/s3"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "public_bucket" {
  source = "../../modules/s3/public"
  name = "ex1"
  acl = "public-read"
}
output "public_bucket_id" {
  value = module.public_bucket.bucket_id
}
output "public_bucket_arn" {
  value = module.public_bucket.bucket_arn
}

module "private_bucket" {
  source = "../../modules/s3/private"
  name = "ex1"
}
output "private_bucket_id" {
  value = module.private_bucket.bucket_id
}
output "private_bucket_arn" {
  value = module.private_bucket.bucket_arn
}

module "log_bucket" {
  source = "../../modules/s3/log"
  name = "ex1"
}
output "log_bucket_id" {
  value = module.log_bucket.bucket_id
}
output "log_bucket_arn" {
  value = module.log_bucket.bucket_arn
}

