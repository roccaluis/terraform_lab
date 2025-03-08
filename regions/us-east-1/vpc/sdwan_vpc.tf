# Calculate subnet CIDRs using the hashicorp/subnets/cidr module for the SD-WAN VPC
module "sdwan_subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"
  
  base_cidr_block = var.network_lab_sdwan_cidr
  networks = flatten([
    for az in local.azs : [
      { name = "sdwan-private1-${az}", new_bits = 5 },
      { name = "sdwan-private2-${az}", new_bits = 5 },
      { name = "sdwan-public1-${az}", new_bits = 5 },
      { name = "sdwan-public2-${az}", new_bits = 5 }
    ]
  ])
}

# Create the SD-WAN VPC
resource "aws_vpc" "sdwan" {
  cidr_block           = var.network_lab_sdwan_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "sdwan-lab"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "sdwan_igw" {
  vpc_id = aws_vpc.sdwan.id
 
  tags = {
    Name        = "sdwan-igw"
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Private Subnets
resource "aws_subnet" "sdwan_private" {
  count             = length(local.azs) * 2 # Two subnets per AZ
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = module.sdwan_subnets.network_cidr_blocks[local.sdwan_private_subnet_names[count.index]]
  availability_zone = local.azs[floor(count.index / 2)]
  
  tags = {
    Name        = local.sdwan_private_subnet_names[count.index]
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Public Subnets
resource "aws_subnet" "sdwan_public" {
  count             = length(local.azs) * 2 # Two subnets per AZ
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = module.sdwan_subnets.network_cidr_blocks[local.sdwan_public_subnet_names[count.index]]
  availability_zone = local.azs[floor(count.index / 2)]
 
  tags = {
    Name        = local.sdwan_public_subnet_names[count.index]
    Terraform   = "true"
    Environment = var.environment
  }
}

# Create Public Route Table
resource "aws_route_table" "sdwan_public" {
  vpc_id = aws_vpc.sdwan.id
 
  tags = merge(
    local.sdwan_public_route_table_tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}

# Add Route to Internet Gateway in Public Route Table
resource "aws_route" "sdwan_public_igw" {
  route_table_id         = aws_route_table.sdwan_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sdwan_igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "sdwan_public" {
  count          = length(local.azs) * 2
  subnet_id      = aws_subnet.sdwan_public[count.index].id
  route_table_id = aws_route_table.sdwan_public.id
}

# Create Private Route Tables (two per AZ)
resource "aws_route_table" "sdwan_private" {
  count  = length(local.azs) * 2 # Two route tables per AZ
  vpc_id = aws_vpc.sdwan.id
  
  tags = merge(
    local.sdwan_private_route_table_tags[count.index],
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "sdwan_private" {
  count          = length(local.azs) * 2
  subnet_id      = aws_subnet.sdwan_private[count.index].id
  route_table_id = aws_route_table.sdwan_private[count.index].id
}

# Manage the Default Route Table
resource "aws_default_route_table" "sdwan_default" {
  default_route_table_id = aws_vpc.sdwan.default_route_table_id

  # No routes are added since subnets use custom route tables
  # Just set the tags to name it
  tags = {
    Name        = "sdwan-lab-default"
    Terraform   = "true"
    Environment = var.environment
  }
}