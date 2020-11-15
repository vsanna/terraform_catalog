provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "./vpc"
  name = "pet"
}

output "vpc" {
  value = module.vpc.vpc_name
}
