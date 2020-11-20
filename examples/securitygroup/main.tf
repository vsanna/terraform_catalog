terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/securitygroup"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "sg1" {
  source = "../../modules/securitygroup"
  name = "sg1"
  port = "80"
  cidr_blocks = ["0.0.0.0/0"]
  vpc_id = {
    id = "id"
    name = "name"
  }
}