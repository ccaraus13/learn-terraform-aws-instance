terraform {
  cloud {
    organization = "kuk-dev-org"
    workspaces {
      name = "learn-terraform-aws-instance"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.28.0"
    }
  }

  required_version = ">= 0.14.0"
}