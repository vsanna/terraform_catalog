provider "aws" {
  region = "ap-northeast-1"
}

module "pet" {
  source = "./pet"
  id = "123123"
}

output "pet2" {
  value = module.pet.pet
}

output "pet2_attr" {
  value = module.pet.pet.id
}

//ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table
data "aws_route_table" "private_subnet_route_table" {
  // OK
//  route_table_id = "rtb-01d4fbdea91784605"

  // OK
//  subnet_id = "subnet-00ab2931a7e841a8f"

  // OK. 単に名前の指定がミスっていたっぽい
  filter {
    name = "tag:Name"
    values = ["route_table:(public_subnet:(vpc:basic-ap-northeast-1c))"]
  }
}

output "pubroute" {
  value = data.aws_route_table.private_subnet_route_table
}

module "randoms" {
  source = "./randoms"
}
output "randoms" {
  value = {
    string = module.randoms.random_string
    integer = module.randoms.random_integer
    id = module.randoms.random_id
    password = module.randoms.random_password
    shuffle = module.randoms.random_shuffle
    uuid = module.randoms.random_uid
    pet = module.randoms.random_pet
  }
}