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
#Allows accessing web server from inet directly, build for Session Managet
#resource "aws_vpc_security_group_ingress_rule" "web_server_in" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Web Servers Security Group Rule"
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 443
#  ip_protocol = "tcp"
#  to_port     = 443
#}

resource "aws_security_group" "web_server" {
  name = "web_server"
  description = "Web Servers Security Group"
  vpc_id = aws_vpc.petcln.id
}

resource "aws_vpc_security_group_ingress_rule" "web_server_container_in" {
  security_group_id = aws_security_group.web_server.id
  description = "Container Security Group Rule"

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 9080
  ip_protocol = "tcp"
  to_port     = 9080
}

resource "aws_vpc_security_group_egress_rule" "web_server_out_http" {
  security_group_id = aws_security_group.web_server.id
  description = "LB Security Group Rule HTTP ${count.index}"

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 9080
  ip_protocol = "tcp"
  to_port     = 9080
}

#TODO do we need this for SSM?
## ssh SG
resource "aws_vpc_security_group_ingress_rule" "web_server_ssh_in" {
  security_group_id = aws_security_group.web_server.id
  description = "Container Security Group Rule"

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

#TODO do we need this for SSM?
resource "aws_vpc_security_group_egress_rule" "web_server_ssh_out" {
  security_group_id = aws_security_group.web_server.id
  description = "LB Security Group Rule HTTP ${count.index}"

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# for ssm
resource "aws_vpc_security_group_egress_rule" "web_server_out_https" {
  security_group_id = aws_security_group.web_server.id
  description = "LB Security Group Rule HTTPS for SSM"

  # set all IPs instead of defining hosts: ec2messages.region.amazonaws.com ssm.region.amazonaws.com ssmmessages.region.amazonaws.com
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}