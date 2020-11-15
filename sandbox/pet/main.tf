variable "id" {}
resource "random_pet" "default" {
  prefix = var.id
}

output "pet" {
  value = random_pet.default
}