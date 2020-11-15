/*
@oaram name name for the new IAM Role
*/

variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAM Role to create
resource "aws_iam_role" "default" {
    name = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Trust Policy for the IAM Role
data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            identifiers = [var.identifier]
            type = "Service"
        }
    }
}

# IAM Policy = what to attach policy document
resource "aws_iam_policy" "default" {
    name = var.name
    policy = var.policy
}

# Attach the IAM Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "example_attach" {
    role = aws_iam_role.default.name
    policy_arn = aws_iam_policy.default.name
}

output "iam_role_arn" {
    value = aws_iam_role.default.arn
}

output "iam_role_name" {
    value = aws_iam_role.default.name
}