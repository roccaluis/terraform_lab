variable "network_lab_cidr" {
  description = "CIDR block for the network-test VPC"
  type        = string
}

variable "network_lab_sdwan_cidr" {
  description = "CIDR block for the network-test-sd-wan VPC"
  type        = string
}

# Reference to parent variables
variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
}