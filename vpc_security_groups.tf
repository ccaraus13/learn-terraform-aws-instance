#
# DB security groups & rules
#
resource "aws_security_group" "petdb" {
  name = "petdb"
  description = "PetClinic DB Instance Security Group"
  vpc_id = aws_vpc.petcln.id

}

resource "aws_vpc_security_group_ingress_rule" "petdb_rule" {
  security_group_id = aws_security_group.petdb.id
  description = "Pet DB Security Group Rule"

#  count = length(var.public_subnets_cidrs)
#
#  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
  referenced_security_group_id = aws_security_group.petdb.id
}

##
## Web Server (Ec2) security groups & rules
##

resource "aws_security_group" "web_server" {
  name = "web_server"
  description = "Web Servers Security Group"
  vpc_id = aws_vpc.petcln.id
}

##
## for ec2 & ssm: VPC Endpoints: `Gateway` type, for S3 connection
##
data "aws_prefix_list" "s3" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${var.region}.s3"]
  }
}

resource "aws_vpc_security_group_egress_rule" "web_server_ssm_s3_out" {
  security_group_id = aws_security_group.web_server.id
  description = "SG SSM for S3 out"

  prefix_list_id = data.aws_prefix_list.s3.id
  ip_protocol = -1

}

##
## for ec2 & ssm: VPC Endpoints `Interface` type
##
resource "aws_vpc_security_group_ingress_rule" "web_server_ssm_443" {
  security_group_id = aws_security_group.web_server.id
  description = "SG SSM private subnet 443"

  count = length(var.private_subnets_cidrs)

  cidr_ipv4   = element(var.private_subnets_cidrs, count.index)
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  # allows traffic only inside security group(since `referenced_security_group_id` and `security_group_id` have the same value)
  #  referenced_security_group_id =  aws_security_group.web_server.id
}

##
## for ec2 & ssm: VPC Endpoints `Interface` type
##
resource "aws_vpc_security_group_egress_rule" "web_server_ssm_out_443" {
  security_group_id = aws_security_group.web_server.id
  description = "SG SSM private subnet 443 out"

  count = length(var.private_subnets_cidrs)

  cidr_ipv4   = element(var.private_subnets_cidrs, count.index)
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  # allows traffic only inside security group(since `referenced_security_group_id` and `security_group_id` have the same value)
#  referenced_security_group_id =  aws_security_group.web_server.id
}

##
## for LB: open port for communication from LB to EC2 instance(EC2 input traffic)
##
resource "aws_vpc_security_group_ingress_rule" "load_balancer_ec2_in" {
  security_group_id = aws_security_group.web_server.id
  description = "Load Balancer & EC2 communication in"

  referenced_security_group_id = aws_security_group.inet_load_balancer.id
  from_port = var.petapp_ec2_port
  to_port = var.petapp_ec2_port
  ip_protocol = "tcp"
}

##
## for LB: open port for communication from EC2 to LB instance(EC2 output traffic)
##
resource "aws_vpc_security_group_egress_rule" "load_balancer_ec2_out" {
  security_group_id = aws_security_group.web_server.id
  description = "Load Balancer & EC2 out"

  referenced_security_group_id =  aws_security_group.inet_load_balancer.id
  from_port = var.petapp_ec2_port
  to_port = var.petapp_ec2_port
  ip_protocol = "tcp"
}

##
## Load Balancer security groups & rules
##
resource "aws_security_group" "inet_load_balancer" {
  vpc_id = aws_vpc.petcln.id
  description = "Internet Facing SG, designed for Load Balancer"
}
##
## for LB: open port opened to internet(input traffic)
##
resource "aws_vpc_security_group_ingress_rule" "load_balancer_inet_in" {
  security_group_id = aws_security_group.inet_load_balancer.id
  description = "Load Balancer listener port(internet facing)"

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

##
## for LB: open port opened to internet(input traffic)
##
resource "aws_vpc_security_group_ingress_rule" "load_balancer_inet_443_in" {
  security_group_id = aws_security_group.inet_load_balancer.id
  description = "Load Balancer listener port(internet facing)"

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
}

##
## for LB: open port for communication from LB to EC2 instance(LB input traffic)
##
resource "aws_vpc_security_group_ingress_rule" "load_balancer_ec2_in2" {
  security_group_id =  aws_security_group.inet_load_balancer.id
  description = "Load Balancer & EC2 communication in (LB input traffic)"

  referenced_security_group_id = aws_security_group.web_server.id
  from_port = var.petapp_ec2_port
  to_port = var.petapp_ec2_port
  ip_protocol = "tcp"
}

##
## for LB: open port for communication from EC2 to LB instance(LB output traffic)
##
resource "aws_vpc_security_group_egress_rule" "load_balancer_ec2_out2" {
  security_group_id =  aws_security_group.inet_load_balancer.id
  description = "Load Balancer & EC2 out"

  referenced_security_group_id = aws_security_group.web_server.id
  from_port = var.petapp_ec2_port
  to_port = var.petapp_ec2_port
  ip_protocol = "tcp"
}
