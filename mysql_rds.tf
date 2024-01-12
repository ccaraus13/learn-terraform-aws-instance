resource "aws_db_subnet_group" "petdb_subnet" {
  name = "petdb_subnet"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "Pet Clinic"
  }
}

resource "aws_db_instance" "petdb" {
  identifier_prefix = "petdb"
  instance_class = var.db_instance_class
  allocated_storage    = 20
  max_allocated_storage = 20
  storage_type = "gp2"
  db_name              = "petclinic"
  engine               = "mysql"
  engine_version       = "8.0.35"
  username             = "admin"
  manage_master_user_password = true
  parameter_group_name = aws_db_parameter_group.petdb.name
  skip_final_snapshot  = true
  s3_import {
    bucket_name           = var.mysql_backup_s3_bucket
    ingestion_role        = var.mysql_restore_from_s3_role
    source_engine         = "mysql"
    source_engine_version = "8.0"
  }

  availability_zone = "eu-central-1a"
#  multi_az =
  db_subnet_group_name = aws_db_subnet_group.petdb_subnet.name
  vpc_security_group_ids = [aws_security_group.petdb.id]
  deletion_protection = false
  network_type = "IPV4"
  port = 3306

  tags = {
    Name = "Pet Clinic"
  }

}

resource "aws_db_parameter_group" "petdb" {
  family = "mysql8.0"
  name = "mysql-8-0-grp"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "lower_case_table_names"
    value = "1"
    apply_method = "pending-reboot"
  }

}

data "aws_db_instance" "petdb"{
  db_instance_identifier = aws_db_instance.petdb.identifier
}

data "aws_secretsmanager_secret" "mysql_master_secret" {
  arn = data.aws_db_instance.petdb.master_user_secret[0].secret_arn
}


## Invokes lambda function that creates an additional DB user&password to be used by the application

data "aws_lambda_invocation" "create_db_api_user_lambda" {
  function_name = aws_lambda_function.create_db_api_user_lambda.function_name
  input         = <<JSON
    {
      "DB_ROOT_SECRET_ID": "${data.aws_secretsmanager_secret.mysql_master_secret.id}",
      "DB_API_USER_SECRET_ID": "${aws_secretsmanager_secret.mysql_api_user_secret.id}",
      "DB_HOST": "${data.aws_db_instance.petdb.address}",
      "DB_PORT": ${data.aws_db_instance.petdb.port}
    }
    JSON
}

locals {
  lambda_invocation_result = jsondecode(data.aws_lambda_invocation.create_db_api_user_lambda.result)
  DB_API_USER_SECRET_ID = local.lambda_invocation_result.status == "OK" ? local.lambda_invocation_result.secret_id : "error"
}