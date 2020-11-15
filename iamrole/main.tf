provider "aws" {
    region = "ap-northeast-1"
}

# IAM policy document = what is allowed/denied
data "aws_iam_policy_document" "allow_describe_regions" {
    statement {
        effect = "Allow"
        actions = ["ec2:DescribeRegions"]
        resources = ["*"]
    }
}

# IAM policy = IAM policy documentをresourceとして扱えるようにしたもの。
resource "aws_iam_policy" "example_policy" {
    name = "example"
    policy = data.aws_iam_policy_document.allow_describe_regions.json
}

# 信頼ポリシー
data "aws_iam_policy_document" "ec2_assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            identifiers = ["ec2.amazonaws.com"]
            type = "Service"
        }
    }
}

resource "aws_iam_role" "example_role" {
    name = "example_role"
    assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "example_attach" {
    role = aws_iam_role.example_role.name
    policy_arn = aws_iam_policy.example_policy.name
}

