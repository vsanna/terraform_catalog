variable "name" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_id" {
    default = ""
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

resource "aws_instance" "default" {
    ami = data.aws_ami.recent_amazon_linux_2.image_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id

    tags = {
        Name = var.name
    }

    user_data = file("${path.module}/start.sh")

    vpc_security_group_ids = [aws_security_group.web_http.id]
}

resource "aws_security_group" "web_http" {
    name = "sg_for:(${var.name})"
    vpc_id = var.vpc_id

    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
    }
}

output "instance_id" {
    value = aws_instance.default.id
}

output "public_dns" {
    value = aws_instance.default.public_dns
}