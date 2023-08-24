##
## Web Server (Ec2) security groups & rules
##
#resource "aws_security_group" "web_server" {
#  name = "web_server"
#  description = "Web Servers Security Group"
#  vpc_id = aws_vpc.petcln.id
#}
#
#resource "aws_vpc_security_group_egress_rule" "web_server_out_https" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Web Server Security Group Rule HTTPS"
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 443
#  ip_protocol = "tcp"
#  to_port     = 443
#}
#
#resource "aws_vpc_security_group_egress_rule" "web_server_out_http" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Web Server Security Group Rule HTTP"
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 80
#  ip_protocol = "tcp"
#  to_port     = 80
#}
#
#resource "aws_vpc_security_group_egress_rule" "web_server_out_db" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Web Server Security Group Rule DB"
#
#  count = length(var.private_subnets_cidrs)
#
#  cidr_ipv4   = element(var.private_subnets_cidrs, count.index)
#  from_port   = 3306
#  ip_protocol = "tcp"
#  to_port     = 3306
#}
#
##Allows accessing web server from inet directly, build for Session Managet
#resource "aws_vpc_security_group_ingress_rule" "web_server_in" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Web Servers Security Group Rule"
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 443
#  ip_protocol = "tcp"
#  to_port     = 443
#}