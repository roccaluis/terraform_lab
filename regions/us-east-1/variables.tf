# Terraform Variables
variable "region" {
  description = "AWS region to deploy the VPCs"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "shimbita-general"
}

# Tag Variables
variable "environment" {
  description = "Environment tag for resources"
  type        = string
  default     = "lab"
}

# VPC Variables
variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "network_lab_cidr" {
  description = "CIDR block for the network-lab VPC"
  type        = string
  default     = "10.50.0.0/22"
}

variable "network_lab_sdwan_cidr" {
  description = "CIDR block for the network-lab-sd-wan VPC"
  type        = string
  default     = "10.51.0.0/22"
}

# Panorama Variables
variable "panorama_key_name" {
  description = "Key pair name for Panorama instance"
  type        = string
  default     = "panorama-lab"
}

# AMI IDs mapping
variable "ami_ids" {
  description = "Map of AMI IDs per region"
  type = map(object({
    panorama       = string
    palo_vm_series = string
    bastion        = string
  }))
  default = {
    "us-east-1" = {
      panorama       = "ami-069035963282c847c"
      palo_vm_series = "ami-01519c6ac6c3563c9"
      bastion        = "ami-0263bd1e615aaf8fe"
    }
    "us-east-2" = {
      panorama       = "ami-0661a5ae8804e5069"
      palo_vm_series = "ami-0cc4bbf78f4743f38"
      bastion        = "ami-072c137559a37aa19"
    }
    "eu-west-1" = {
      panorama       = "ami-0ac5089f376cd51b9"
      palo_vm_series = "ami-063cb1655f972b9ea"
      bastion        = "ami-04d6cff5f6bd158c5"
    }
    "ap-northeast-1" = {
      panorama       = "ami-089d51846fc459945"
      palo_vm_series = "ami-0f63b4474c8f3c0d0"
      bastion        = "ami-0d007e31afb2e6a6e"
    }
  }
}