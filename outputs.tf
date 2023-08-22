#output "instance_ami" {
#  value = aws_instance.app_server.ami
#}
#
#output "instance_arn" {
#  value = aws_instance.app_server.arn
#}

output "petdb_hostname"{
  description = "Pet DB hostname"
  value = aws_db_instance.petdb.address
}

output "petdb_port"{
  description = "Pet DB port"
  value = aws_db_instance.petdb.port
}

output "petdb_username"{
  description = "Pet DB username"
  value = aws_db_instance.petdb.username
}