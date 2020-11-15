provider "random" {}

resource "random_integer" "rint" {
  max = 1000
  min = 0
  # when any attr of this keepers map changes, random_integer.rint.result will be regenerated
  keepers = {
    some_integer = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_string" "rstring" {
  length = 32
  upper = true
  lower = true
  special = true
  number = true
  override_special = "_%$"

  keepers = {
    some_string = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_id" "rid" {
  byte_length = 32
  keepers = {
    some_id = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_password" "rpassword" {
  length = 32
  special = true
  override_special = "_%@"
  keepers = {
    some_password = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_shuffle" "rshuffle" {
  input = ["apple", "orange", "banana", "kiwi"]
  result_count = 2
  keepers = {
    some_shuffle_result = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_uuid" "ruuid" {
  keepers = {
    some_uuid = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

resource "random_pet" "rpet" {
  keepers = {
    some_pet = "if_you_change_this_value_then_result_will_be_regenerated"
  }
}

output "random_string" {
  value = random_string.rstring.result
}
output "random_integer" {
  value = random_integer.rint.result
}
output "random_id" {
  value = random_id.rid.hex
}
output "random_password" {
  value = random_password.rpassword.result
}
output "random_shuffle" {
  value = random_shuffle.rshuffle.result
}
output "random_uid" {
  value = random_uuid.ruuid.result
}
output "random_pet" {
  value = random_pet.rpet.id
}
