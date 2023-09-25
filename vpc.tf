resource "aws_vpc" "petcln" {
  cidr_block = "10.0.0.0/16"

  # required for SSM, so that AWS DNS Server(Route 53) can resolve and forward respective traffic, relates to `private hosted zone`
  enable_dns_hostnames = true
  enable_dns_support = true

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
##
## Enable internet access
##
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
    Name = "Inet and Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count = length(var.public_subnets_cidrs)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.rtb_public.id
}


# VPC `Interface` endpoint(uses AWS PrivateLink) - sends traffic to a named service
# The endpoint for the Systems Manager service.
# Required by System Manager
resource "aws_vpc_endpoint" "ssm" {
  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
#  policy = "" # defaults to full access

  tags = {
    Name = "ssm"
  }
}

# VPC `Interface` endpoint(uses AWS PrivateLink) - sends traffic to a named service
# Systems Manager uses this endpoint to make calls from SSM Agent(installed on EC2) to the Systems Manager service.
# Required by System Manager
resource "aws_vpc_endpoint" "ssm_ec2messages" {
  service_name = "com.amazonaws.${var.region}.ec2messages"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "ssm_ec2messages"
  }
}

# VPC `Interface` endpoint(uses AWS PrivateLink) - sends traffic to a named service
# Used by System Manager for VSS-enabled snapshots(backup) and to enumerate Amazon EBS volumes
# Required by System Manager
resource "aws_vpc_endpoint" "ssm_ec2" {
  service_name = "com.amazonaws.${var.region}.ec2"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "ssm_ec2"
  }
}

# VPC `Interface` endpoint(uses AWS PrivateLink) - sends traffic to a named service
# This endpoint is required only if you're connecting to your instances through a secure data channel using Session Manager. SSH ?
# Required by System Manager
resource "aws_vpc_endpoint" "ssm_ssmmessages" {
  service_name = "com.amazonaws.${var.region}.ssmmessages"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "ssm_ssmmessages"
  }
}

# VPC `Gateway` endpoint - sends traffic to a named service
#  Systems Manager uses this endpoint to update SSM Agent and to perform patching operations.
# Systems Manager also uses this endpoint for tasks like uploading output logs you choose to store in S3 buckets,
# retrieving scripts or other files you store in buckets, and so on.
resource "aws_vpc_endpoint" "cloud_watch" {
  service_name = "com.amazonaws.${var.region}.logs"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "cloud_watch"
  }
}

#for accessing docker images from ECR
resource "aws_vpc_endpoint" "ecr_api" {
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "ecr_api"
  }
}

#for accessing docker images from ECR
resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.web_server.id]
  # magic here: without it Fleet Manager cannot discover EC2 instance
  private_dns_enabled = true
  ip_address_type = "ipv4"
  #  policy = "" # defaults to full access

  tags = {
    Name = "ecr_dkr"
  }
}

# gateway endpoint - sends traffic to a S3 service
resource "aws_vpc_endpoint" "ssm_s3" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_id       = aws_vpc.petcln.id
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.for_s3_rt.id]
  #  policy = "" # defaults to full access

  tags = {
    Name = "ssm_s3"
  }
}

# Each subnet route table must have a route that sends traffic destined for the service to the gateway endpoint using the prefix list for the service
# Route table required especially for SSM S3 `Gateway` VPC endpoint
resource "aws_route_table" "for_s3_rt" {
  vpc_id = aws_vpc.petcln.id
}

# same as defining `route_table_ids` in endpoint definition
#resource "aws_vpc_endpoint_route_table_association" "for_s3_rt" {
#  route_table_id  = aws_route_table.for_s3_rt.id
#  vpc_endpoint_id = aws_vpc_endpoint.ssm_s3.id
#}

resource "aws_route_table_association" "private_subnet_asso" {
  count = length(var.private_subnets_cidrs)
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.for_s3_rt.id
}