resource "aws_vpc" "petcln" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Pet clinic VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.petcln.id
  count = length(var.public_subnets_cidrs)
  cidr_block = element(var.public_subnets_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  #assign public IP(at lunch) only for subnet in AZ with index 0(for testing purposes)
#  map_public_ip_on_launch = count.index == 0

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.petcln.id
  count = length(var.private_subnets_cidrs)
  cidr_block = element(var.private_subnets_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "inet_gw" {
  vpc_id = aws_vpc.petcln.id

  tags = {
    Name = "Pet clinic Internet Gateway"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.petcln.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet_gw.id
  }

  tags = {
    Name = "2nd Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count = length(var.public_subnets_cidrs)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.rtb_public.id
}

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