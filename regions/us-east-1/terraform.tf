terraform {
  required_version = ">=1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.87.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }

#   backend "s3" {
#     bucket         = "shimbita-network-lab-tf-states"
#     key            = "regions/us-west-2/terraform.tfstate"
#     region         = "us-east-1" # Keep the bucket region for the backend
#     encrypt        = true
#     dynamodb_table = "shimbita-network-lab-tf-locks" # Your DynamoDB table for locking
#     profile        = var.aws_profile
#   }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}