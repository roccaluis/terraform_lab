terraform {
  required_version = ">=1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.87.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = "iamadmin-general"
  }

  variable "aws_region" {
  description = "The AWS region to operate in"
  type        = string
  default     = "us-east-1"
}

