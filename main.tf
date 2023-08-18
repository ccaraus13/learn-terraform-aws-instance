provider "aws" {
  region = var.region
}

#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#    #"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
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
#resource "aws_instance" "app_server" {
#  ami           = data.aws_ami.ubuntu.id
#  instance_type = var.instance_type
#
#  tags = {
#    Name = var.instance_name
#  }
#}