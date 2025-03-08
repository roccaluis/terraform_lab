# Calculate subnet CIDRs using the hashicorp/subnets/cidr module
module "network_lab_subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"
  
  base_cidr_block = var.network_lab_cidr
  networks = concat(
    [for az in local.azs : { name = "private-${az}", new_bits = 2 }],
    [for az in local.azs : { name = "public-${az}", new_bits = 5 }]
  )
}

# Create the main VPC
resource "aws_vpc" "network_lab" {
  cidr_block           = var.network_lab_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "network-lab"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "network_lab_igw" {
  vpc_id = aws_vpc.network_lab.id
 
  tags = {
    Name        = "network-lab-igw"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Private Subnets
resource "aws_subnet" "network_lab_private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.network_lab.id
  cidr_block        = module.network_lab_subnets.network_cidr_blocks["private-${local.azs[count.index]}"]
  availability_zone = local.azs[count.index]
  
  tags = {
    Name        = local.private_subnet_names[count.index]
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Public Subnets
resource "aws_subnet" "network_lab_public" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.network_lab.id
  cidr_block        = module.network_lab_subnets.network_cidr_blocks["public-${local.azs[count.index]}"]
  availability_zone = local.azs[count.index]
  
  tags = {
    Name        = local.public_subnet_names[count.index]
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Public Route Table
resource "aws_route_table" "network_lab_public" {
  vpc_id = aws_vpc.network_lab.id
 
  tags = {
    Name        = "network-lab-public"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Add Route to Internet Gateway in Public Route Table
resource "aws_route" "network_lab_public_igw" {
  route_table_id         = aws_route_table.network_lab_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.network_lab_igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "network_lab_public" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.network_lab_public[count.index].id
  route_table_id = aws_route_table.network_lab_public.id
}

# Create Private Route Tables (one per AZ)
resource "aws_route_table" "network_lab_private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.network_lab.id
  
  tags = {
    Name        = "network-lab-private-${local.azs[count.index]}"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create NAT Gateways (one per AZ since single_nat_gateway = false)
resource "aws_eip" "network_lab_nat" {
  count  = length(local.azs)
  domain = "vpc"
  
  tags = {
    Name        = "network-lab-nat-eip-${local.azs[count.index]}"
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "network_lab_nat" {
  count         = length(local.azs)
  allocation_id = aws_eip.network_lab_nat[count.index].id
  subnet_id     = aws_subnet.network_lab_public[count.index].id
  
  tags = {
    Name        = "network-lab-nat-${local.azs[count.index]}"
    Terraform   = "true"
    Environment = var.environment
  }
  
  # To ensure proper ordering, it's recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.network_lab_igw]
}

# Add Route to NAT Gateway in Private Route Tables
resource "aws_route" "network_lab_private_nat" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.network_lab_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.network_lab_nat[count.index].id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "network_lab_private" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.network_lab_private[count.index].id
  route_table_id = aws_route_table.network_lab_private[count.index].id
}

# Manage the Default Route Table
resource "aws_default_route_table" "network_lab_default" {
  default_route_table_id = aws_vpc.network_lab.default_route_table_id

  # No routes are added since subnets use custom route tables
  tags = {
    Name        = "network-lab-default"
    Terraform   = "true"
    Environment = var.environment
  }
}