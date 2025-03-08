locals {
  # Reference the data source from parent folder
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  
  # Generate subnet names dynamically with AZ names appended
  private_subnet_names = [for az in local.azs : "private-${az}"]
  public_subnet_names  = [for az in local.azs : "public-${az}"]
  
  # Generate route table names dynamically
  private_route_table_tags = {
    for az in local.azs :
    az => { Name = "network-lab-private-${az}" }
  }
  
  # Private and public subnet names (two per AZ for SD-WAN VPC)
  sdwan_private_subnet_names = flatten([for az in local.azs : ["sdwan-private1-${az}", "sdwan-private2-${az}"]])
  sdwan_public_subnet_names = flatten([for az in local.azs : ["sdwan-public1-${az}", "sdwan-public2-${az}"]])
  
  # Generate private route table tags as a list (two per AZ)
  sdwan_private_route_table_tags = flatten([for az in local.azs : [{ Name = "sdwan-lab-private-${az}-1" }, { Name = "sdwan-lab-private-${az}-2" }]])
  
  sdwan_public_route_table_tags = {
    Name = "sdwan-lab-public"
  }
}