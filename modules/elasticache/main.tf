/*
NOTE:
after creating a new RDS, update password by aws cli command below
aws rds modify-db-instance --db-instance-identifier {name} --master-user-password {actual_password}
*/

variable "name" {}
variable "instance_level" {
  default = "cache.m3.medium"
}
variable "vpc_id" {}
variable "vpc_cider_blocks" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}

resource "aws_elasticache_parameter_group" "default" {
  family = "redis5.0"
  name = var.name

//  parameter {
//    name = "cluster-enabled"
//    value = "true"
//  }
}

resource "aws_elasticache_subnet_group" "default" {
  name = "default"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id = "default"
  replication_group_description = "cluster is disabled"

  engine = "redis"
  engine_version = "5.0.4"

  // number of nodes
  number_cache_clusters = 3
  node_type = var.instance_level
  snapshot_window = "09:10-10:10"
  snapshot_retention_limit = 7
  maintenance_window = "mon:10:40-mon:11:40"
  automatic_failover_enabled = true
  port = 6379
  apply_immediately = false
  security_group_ids = [module.redis_sg.security_group_id]
  parameter_group_name = aws_elasticache_parameter_group.default.name
  subnet_group_name = aws_elasticache_subnet_group.default.name
}


module "redis_sg" {
  source = "../securitygroup"
  name = "redis_${var.name}"
  vpc_id = var.vpc_id
  port = 3306
  cidr_blocks = var.vpc_cider_blocks
}