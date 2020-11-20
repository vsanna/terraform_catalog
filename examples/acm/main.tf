terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/acm"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "acm" {
  source = "../../modules/acm"
  domain_name = "example.com"
}

output "acm_id" {
  value = module.acm.acm_id
}