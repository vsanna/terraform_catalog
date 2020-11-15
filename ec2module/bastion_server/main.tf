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
    key_name = aws_key_pair.primary_key.id
    vpc_security_group_ids = [aws_security_group.for_bastion.id]

    tags = {
        Name = var.name
    }
}



resource "aws_security_group" "for_bastion" {
    name = "sg_for:(${var.name})"
    vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "sh" {
    security_group_id = aws_security_group.for_bastion.id
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
}

resource "aws_security_group_rule" "icmp" {
    security_group_id = aws_security_group.for_bastion.id
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
}

resource "aws_security_group_rule" "all" {
    security_group_id = aws_security_group.for_bastion.id
    type              = "egress"
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
}

# DO NOT SHARE THIS KEY
resource "aws_key_pair" "primary_key" {
    key_name = "kp:(${var.name})"
    # TODO: replace variable
    public_key = file("/Users/ryu.ishikawa/.ssh/id_rsa.pub")
}

output "instance_id" {
    value = aws_instance.default.id
}

output "public_dns" {
    value = aws_instance.default.public_dns
}