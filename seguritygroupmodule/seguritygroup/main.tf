variable "name" {}
variable "vpc" {
  type = object({id: string, name: string})
}
variable "port" {}
variable "cidr_blocks" {
  type = list(string)
}

resource "aws_security_group" "default" {
  name = "sg:${var.name}"
  vpc_id = var.vpc.id
}

resource "aws_security_group_rule" "inbound" {
  security_group_id = aws_security_group.default.id
  name = "sg_ingress:(${aws_security_group.default.name})"
  type = "ingress"

  # [from,to]をrangeとして開ける。同じ値なので固定の値のみ通す
  from_port = var.port
  to_port = var.port
  protocol = "tcp"
  cidr_blocks = var.cidr_blocks
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = aws_security_group.default.id
  name = "sg_ingress:(${aws_security_group.default.name})"
  type = "egress"

  # 外にはすべての通信を通す
  from_port = 0
  to_port = 0
  # -1 == all
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


/*
# another way to define sg with sgrules at once
resource "aws_security_group" "web_http" {
    name = "web_http"

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
*/

output "security_group_id" {
  value = aws_security_group.default.id
}