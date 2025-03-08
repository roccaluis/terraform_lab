# VPC outputs for use by other resources
output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.network_lab.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC"
  value       = aws_vpc.network_lab.cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.network_lab_private[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.network_lab_public[*].id
}

output "public_subnet_names" {
  description = "List of IDs of public subnets"
  value       = local.public_subnet_names
}

output "sdwan_vpc_id" {
  description = "The ID of the SD-WAN VPC"
  value       = aws_vpc.sdwan.id
}

output "sdwan_vpc_cidr" {
  description = "The CIDR block of the SD-WAN VPC"
  value       = aws_vpc.sdwan.cidr_block
}

output "sdwan_private_subnet_ids" {
  description = "List of IDs of SD-WAN private subnets"
  value       = aws_subnet.sdwan_private[*].id
}

output "sdwan_public_subnet_ids" {
  description = "List of IDs of SD-WAN public subnets"
  value       = aws_subnet.sdwan_public[*].id
}