terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/ecr"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "ecr" {
  source = "../../modules/ecr"
  name = "sample"
}

