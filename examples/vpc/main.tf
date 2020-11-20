terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/network"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../../modules/network/vpc"
  name = "pet"
}

output "vpc" {
  value = module.vpc.vpc_name
}

