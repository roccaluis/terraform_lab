# Import VPC module
module "vpc" {
  source = "./vpc"
  
  # Passes the environment variable (e.g., "test") to the module for tagging resources.
  environment = var.environment
  # Passes the number of Availability Zones (AZs) to use (default is 2).
  az_count = var.az_count

  # Passes the CIDR block for the "network-test" VPC (default "10.50.0.0/22")
  network_lab_cidr = var.network_lab_cidr
  # Passes the CIDR block for the "sdwan-test" VPC (default "10.51.0.0/22").
  network_lab_sdwan_cidr = var.network_lab_sdwan_cidr
 }