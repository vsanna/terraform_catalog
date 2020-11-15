provider "aws" {
  region = "ap-northeast-1"
}

module "sg1" {
  source = "./seguritygroup"
  name = "sg1"
  port = "80"
  cidr_blocks = ["0.0.0.0/0"]
  vpc = {
    id = "id"
    name = "name"
  }
}