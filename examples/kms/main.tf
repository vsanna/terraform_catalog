terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/iamrole"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "key" {
  source = "../../modules/kms/key"
  description = "test"
}

module "alias" {
  source = "../../modules/kms/alias"
  name = "alias1"
  key_id = module.key.key_id
}

