#output "instance_ami" {
#  value = aws_instance.app_server.ami
#}
#
#output "instance_arn" {
#  value = aws_instance.app_server.arn
#}

#output "petdb_hostname"{
#  description = "Pet DB hostname"
#  value = aws_db_instance.petdb.address
#  sensitive = true
#}
#
#output "petdb_port"{
#  description = "Pet DB port"
#  value = aws_db_instance.petdb.port
#  sensitive = true
#}
#
#output "petdb_username"{
#  description = "Pet DB username"
#  value = aws_db_instance.petdb.username
#  sensitive = true
#}
#
#output "petdb_password"{
#  description = "Pet DB username"
#  value = aws_db_instance.petdb.password
#  sensitive = true
#}

#output "lb_dns" {
#  description = "Load Balancer DNS"
#  value = aws_alb.petapp.dns_name
#}