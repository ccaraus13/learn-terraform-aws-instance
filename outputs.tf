#output "instance_ami" {
#  value = aws_instance.app_server.ami
#}
#
#output "instance_arn" {
#  value = aws_instance.app_server.arn
#}

#output "petdb_hostname"{
#  description = "Pet DB address"
#  value = aws_db_instance.petdb.address
#  sensitive = true
#}
#
#output "petdb_port"{
#  description = "Pet DB port"
#  value = aws_db_instance.petdb.port
#  sensitive = false
#}
#
#output "petdb_endpoint"{
#  description = "Pet DB endpoint"
#  value = aws_db_instance.petdb.endpoint
#  sensitive = false
#}
#
#output "petdb_engine"{
#  description = "Pet DB engine"
#  value = aws_db_instance.petdb.engine
#  sensitive = false
#}
#
#output "petdb_full_url"{
#  description = "Pet DB full url"
#  value = format("jdbc:%s://%s/%s", aws_db_instance.petdb.engine, aws_db_instance.petdb.endpoint, aws_db_instance.petdb.db_name)
#  sensitive = false
#}
#
#output "petdb_username"{
#  description = "Pet DB username"
#  value = aws_db_instance.petdb.username
#  sensitive = false
#}

#output "petdb_password"{
#  description = "Pet DB username"
#  value = aws_db_instance.petdb.password
#  sensitive = true
#}

#output "lb_dns" {
#  description = "Load Balancer DNS"
#  value = aws_alb.petapp.dns_name
#}

#output "db_host" {
#  value = jsondecode(data.aws_secretsmanager_secret_version.mysql_master_secret.secret_string)["host"]
#  sensitive = false
#}
#
#output "db_master_username" {
#  value = jsondecode(data.aws_secretsmanager_secret_version.mysql_master_secret.secret_string)["username"]
#  sensitive = false
#}

output "db_api_user_secret_id" {
  value = aws_secretsmanager_secret.mysql_api_user_secret.id
  sensitive = false
}

output "create_db_api_user_lambda_result" {
  value = data.aws_lambda_invocation.create_db_api_user_lambda.result
}