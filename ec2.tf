#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["amazon"] # Canonical
#}
#
#resource "aws_iam_instance_profile" "ssm_profile" {
#  name_prefix = "ssm_profile"
#  # name of the already defined role
#  role = "AmazonSSMRoleForInstancesQuickSetup"
#}
#
#resource "aws_instance" "app_server" {
#  ami           = data.aws_ami.ubuntu.id
#  instance_type = var.instance_type
#  subnet_id = aws_subnet.public_subnets[0].id
#  vpc_security_group_ids = [aws_security_group.web_server.id]
#  iam_instance_profile = aws_iam_instance_profile.ssm_profile.id
#
#  tags = {
#    Name = var.instance_name
#  }
#}