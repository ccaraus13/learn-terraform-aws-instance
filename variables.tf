variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

#variable "instance_type" {
#  description = "Type of EC2 instance to provision"
#  default     = "t2.micro"
#}
#
#variable "instance_name" {
#  description = "AWS EC2 instance name"
#  default     = "Provisioned bt Terraform"
#}

variable "public_subnets_cidrs" {
  type = list(string)
  description = "Public Subnet CIDR value"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidrs" {
  type = list(string)
  description = "Private Subnet CIDR value"
  default = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
  default = ["eu-central-1a", "eu-central-1b"]
}