terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "recipes/basic_network"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "public_bucket" {
  source = "./public_bucket"
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
  source = "./private_bucket"
  name = "ex1"
}
output "private_bucket_id" {
  value = module.private_bucket.bucket_id
}
output "private_bucket_arn" {
  value = module.private_bucket.bucket_arn
}

module "log_bucket" {
  source = "./log_bucket"
  name = "ex1"
}
output "log_bucket_id" {
  value = module.log_bucket.bucket_id
}
output "log_bucket_arn" {
  value = module.log_bucket.bucket_arn
}

