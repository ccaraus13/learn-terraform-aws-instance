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
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.petcln.id
  count = length(var.private_subnets_cidrs)
  cidr_block = element(var.private_subnets_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

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