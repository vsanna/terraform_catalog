terraform {
    backend "s3" {
        bucket = "dd-tfstate"
        key = "examples/ec2"
        region = "ap-northeast-1"
    }
}

provider "aws" {
    region = "ap-northeast-1"
}

module "web" {
    source = "../../modules/ec2/web_server"
    instance_type = "t3.micro"
    name = "web"
    vpc_id = ""
}

output "public_dns" {
    value = module.web.public_dns
}

output "instance_id" {
    value = module.web.instance_id
}

