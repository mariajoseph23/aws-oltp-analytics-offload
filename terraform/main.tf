data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_password" "db" {
  length  = 20
  special = true
}

resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Allow MySQL from allowed CIDR"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_parameter_group" "mysql" {
  name   = "${var.name}-mysql-pg"
  family = "mysql8.0"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "1"
  }
}

resource "aws_db_instance" "oltp" {
  identifier             = "${var.name}-oltp"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = var.db_username
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.mysql.name

  publicly_accessible     = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 1
}

resource "aws_db_instance" "replica" {
  identifier             = "${var.name}-replica"
  replicate_source_db    = aws_db_instance.oltp.identifier
  instance_class         = var.db_instance_class
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  deletion_protection = false
}

resource "aws_s3_bucket" "analytics" {
  bucket        = "${var.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_versioning" "analytics" {
  bucket = aws_s3_bucket.analytics.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics" {
  bucket = aws_s3_bucket.analytics.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_glue_catalog_database" "db" {
  name = replace("${var.name}", "-", "_")
}

resource "aws_athena_workgroup" "wg" {
  name = "${var.name}-wg"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.analytics.bucket}/athena-results/"
    }
  }

  force_destroy = true
}
