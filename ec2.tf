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
#  key_name = "default-hercules-cluster-key-pair"
#  tags = {
#    Name = var.instance_name
#  }
#}

################################
# Get AMI id for EC2 instance
data "aws_ssm_parameter" "linux2_optimized" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "app_container_demo_template" {
  name_prefix = "pet-container"
  # "Name": "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
  image_id = data.aws_ssm_parameter.linux2_optimized.value
  instance_type = var.instance_type

#  iam_instance_profile {
#    arn = aws_iam_instance_profile.ecsInstanceRole_profile.arn
#  }

  user_data = base64encode( templatefile("bash_scripts/ec2_container_user_data.tftpl", { cluster_name = "herculesdemon" }) )
  key_name = "default-hercules-cluster-key-pair"

  network_interfaces {
    subnet_id = aws_subnet.public_subnets[0].id
    security_groups = [aws_security_group.web_server.id]
#    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Pet EC2 Host container"
    }
  }
}

#resource "aws_iam_instance_profile" "ecsInstanceRole_profile" {
#  name_prefix = "ecsInstanceRole-profile"
#  # name of the already defined role
##  role = "ecsInstanceRole"
#  role = "AmazonSSMRoleForInstancesQuickSetup"
#
#}

resource "aws_instance" "petdemon" {

  launch_template {
    id = aws_launch_template.app_container_demo_template.id
    version = "$Latest"
  }
}