variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  # t2.micro = 1 vCPU; 1 GB
  # t3.micro = 2 vCPU; 1 GB
  default     = "t2.micro"
}

variable "instance_name" {
  description = "AWS EC2 instance name"
  default     = "Provisioned bt Terraform"
}


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

variable "availability_zones" {
  type = list(string)
  description = "Availability zones"
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "db_instance_class" {
  type = string
  description = "DB instance class, e.g. db.t3.micro"
  default = "db.t3.micro"
}

variable "petapp_image" {
  type = string
  description = "Docker image of the PetClinic application"
  default = "133566492045.dkr.ecr.eu-central-1.amazonaws.com/nginx-demon:hello9080-0"
}
