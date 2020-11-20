/*
how to ssh-login the instance via session manager
$ aws ssm start-session --target {ec2-instance-id} --document-name SSM-SessionManagerRunShell
*/
variable "name" {}
variable "subnet_id" {}


data "aws_iam_policy_document" "session_manager" {
  source_json = data.aws_iam_policy_document.session_manager.json

  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt",
    ]
  }


  // not to detect changes if value is changed via aws cli
  lifecycle {
    ignore_changes = [value]
  }
  policy = ""
}

data "aws_iam_policy" "session_manager" {
  arn = "arn:aws:iam:aws:policy/AmazonSSMManagedInstanceCore"
}

module "session_manager_role" {
  source = "../iamrole"
  name = "session_manager"
  identifier = "session_manager"
  policy = data.aws_iam_policy_document.session_manager.json
}

// how to associate iam_role with ec2
resource "aws_iam_instance_profile" "session_manager" {
  name = "session_manager"
  role = module.session_manager_role.iam_role_name
}

// this ec2 provides developes with running docker within given VPC
resource "aws_instance" "session_manager" {
  # TODO: use ec2 module
  ami = "ami-0c3fd0f5d33134a76"

  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.session_manager.name
  subnet_id = var.subnet_id
  user_data = file("./user_data.sh")
}

resource "aws_ssm_document" "default" {
  document_format = "json"
  document_type = "Shell"
  name = "SSM-SessionManagerRunShell"

  content = file("./ssm_document.json")
}