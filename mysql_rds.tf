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
  username             = "dev"
  password             = "develop0" #TODO move to KMS
  parameter_group_name = aws_db_parameter_group.petdb.name
  skip_final_snapshot  = true
  s3_import {
    bucket_name           = "percona-pet-mysql-backup"
#    bucket_prefix         = "backups"
    ingestion_role        = "arn:aws:iam::133566492045:role/MysqlBackupFromS3"
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