provider "aws" {
    region = "ap-northeast-1"
}

variable "example_instance_type" {
    default = "t3.micro"
}

data "aws_ami" "recent_amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
    }

    filter {
        name = "state"
        values = ["available"]
    }
}

resource "aws_instance" "example" {
//    ami = "ami-0c3fd0f5d33134a76"
    ami = data.aws_ami.recent_amazon_linux_2.image_id
    instance_type = var.example_instance_type

    tags = {
        Name = "hey"
    }

//    user_data = <<EOF
//#!/bin/bash
//yum install -y httpd
//systemctl start httpd.service
//EOF

    user_data = file("./start.sh")

    vpc_security_group_ids = [aws_security_group.example_ec2.id]
}

resource "aws_security_group" "example_ec2" {
    name = "example-ec2"

    # 任意のipから80へのtcpを受け付ける
    ingress {
        protocol = "tcp"
        # [to,from]の間のrangeを示す.
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        protocol = "-1" # = all
        to_port = 0
    }
}

output "instance_id" {
    value = aws_instance.example.id
}

output "security_group_id" {
    value = aws_instance.example.public_dns
}