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

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

##
## Web Server (Ec2) security groups & rules
##

resource "aws_security_group" "web_server" {
  name = "web_server"
  description = "Web Servers Security Group"
  vpc_id = aws_vpc.petcln.id
}

###
### For SSH
###
#resource "aws_vpc_security_group_ingress_rule" "web_server_ssh_in" {
#  security_group_id = aws_security_group.web_server.id
#  description = "Container Security Group Rule"
#
#  count = length(var.public_subnets_cidrs)
#
#  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
#  from_port   = 22
#  ip_protocol = "tcp"
#  to_port     = 22
#}
#
###
### For SSH
###
#resource "aws_vpc_security_group_egress_rule" "web_server_ssh_out" {
#  security_group_id = aws_security_group.web_server.id
#  description = "LB Security Group Rule HTTP ${count.index}"
#
#  count = length(var.public_subnets_cidrs)
#
#  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
#  from_port   = 22
#  ip_protocol = "tcp"
#  to_port     = 22
#}

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

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
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

  count = length(var.public_subnets_cidrs)

  cidr_ipv4   = element(var.public_subnets_cidrs, count.index)
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  # allows traffic only inside security group(since `referenced_security_group_id` and `security_group_id` have the same value)
#  referenced_security_group_id =  aws_security_group.web_server.id
}
