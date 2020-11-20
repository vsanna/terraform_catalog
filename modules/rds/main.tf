/*
NOTE:
after creating a new RDS, update password by aws cli command below
aws rds modify-db-instance --db-instance-identifier {name} --master-user-password {actual_password}
*/

variable "name" {}
variable "instance_level" {
  default = "db.t3.small"
}
variable "vpc_id" {}
variable "vpc_cider_blocks" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}

// corresponding to my.cnf
resource "aws_db_parameter_group" "default" {
  name = "default"
  family = "mysql5.7"

  parameter {
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "default" {
  name = "default"
  engine_name = "mysql"
  major_engine_version = "5.7"

  // options for DB engine.
//  option {
//    option_name = "MARIADB_AUDIT_PLUGIN"
//  }
}

resource "aws_db_subnet_group" "default" {
  name = "default"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "default" {
  deletion_protection = true

  identifier = "rds:(${var.name})"
  engine = "mysql"
  engine_version = "5.7.25"
  instance_class = var.instance_level

  allocated_storage = 20      // GB
  max_allocated_storage = 100 // GB
  storage_type = "gp2"        // SSD

  storage_encrypted = true
  kms_key_id = module.kms_key.key_arn

  username = "admin"
  password = "shuold_be_change_later"

  multi_az = true
  publicly_accessible = fal

  backup_window = "09:10-09:30" // UTC
  backup_retention_period = 30  // days
  maintenance_window = "mon:10:10-mon:10:30" // UTC

  auto_minor_version_upgrade = false
  // DON'T SKIP generating final snapshot.
  skip_final_snapshot = false

  port = 3306
  vpc_security_group_ids = [module.mysql_sg.security_group_id]

  // when to apply config changes. in maintenance_window or immediately
  apply_immediately = false
  parameter_group_name = aws_db_parameter_group.default.name
  option_group_name = aws_db_option_group.default.name
  db_subnet_group_name = aws_db_subnet_group.default.name

  lifecycle {
    ignore_changes = [password]
  }
}

module "kms_key" {
  source = "../kms/key"
  description = "for rds(${var.name})"
}

module "mysql_sg" {
  source = "../securitygroup"
  name = "rds_${var.name}"
  vpc_id = var.vpc_id
  port = 3306
  cidr_blocks = var.vpc_cider_blocks
}