terraform {
    backend "s3" {
        bucket = "dd-tfstate"
        key = "examples/iamrole"
        region = "ap-northeast-1"
    }
}

provider "aws" {
    region = "ap-northeast-1"
}

module "iamrole" {
    source = "../../modules/iamrole"
    name = "describe-regions-for-ec2"
    identifier = "ec2.amazonaws.com"
    policy = data.aws_iam_policy_document.allow_describe_regions.json
}

# IAM policy document = what is allowed/denied
data "aws_iam_policy_document" "allow_describe_regions" {
    statement {
        effect = "Allow"
        actions = ["ec2:DescribeRegions"]
        resources = ["*"]
    }
}


output "iam_role_arn" {
    value = module.iamrole.iam_role_arn
}

output "iam_role_name" {
    value = module.iamrole.iam_role_name
}

