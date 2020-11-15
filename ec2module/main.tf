provider "aws" {
    region = "ap-northeast-1"
}

module "web" {
    source = "./web_server"
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

