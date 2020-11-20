variable "name" {}

resource "aws_ssm_parameter" "default" {
  name = var.name
  type = "SecureString"
  value = "this_value_should_be_changed_via_aws_cli"


  // not to detect changes if value is changed via aws cli
  lifecycle {
    ignore_changes = [value]
  }
}