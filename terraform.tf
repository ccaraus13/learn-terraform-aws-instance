terraform {
  cloud {
    organization = "kuk-dev-org"
    workspaces {
      name = "learn-terraform-aws-instance"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
#      version = "~> 5.11.0"
    }
  }

  required_version = ">= 1.2.0"
}