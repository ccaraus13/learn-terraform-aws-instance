resource "random_password" "mysql_api_user_password" {
  length = 16
  special = true
  numeric = true
  upper = true
  lower = true
}

resource "aws_secretsmanager_secret" "mysql_api_user_secret" {
  depends_on = [
    aws_db_instance.petdb
  ]
  name = "mysql_api_user_secret-12"
  description = "Credentials For Mysql DB, to be ued by application(other then `master` credentials defined in RDS)"
  #number of days after secret will deleted when deletion was asked
  recovery_window_in_days = 7

  tags = {
    Name = "mysql_api_user_secret"
  }
}

resource "aws_secretsmanager_secret_version" "mysql_api_user_secret" {
  secret_id = aws_secretsmanager_secret.mysql_api_user_secret.id
  secret_string = jsonencode(
    {
      engine = aws_db_instance.petdb.engine
      host = aws_db_instance.petdb.address
      username = var.mysql_api_username
      password = random_password.mysql_api_user_password.result
      dbname = aws_db_instance.petdb.db_name
      port = aws_db_instance.petdb.port
    }
  )
}

# TODO rotation of the secrets with lambda: rotate db_api_user secret and notify application that the secret was changed?
# https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html
