variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "AWS EC2 instance name"
  default     = "Provisioned bt Terraform"
}