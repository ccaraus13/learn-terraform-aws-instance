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
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}