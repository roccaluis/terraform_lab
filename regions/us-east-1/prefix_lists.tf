resource "aws_ec2_managed_prefix_list" "panorama_allowed" {
  name           = "Panorama Allowed CIDRs"
  address_family = "IPv4"
  max_entries    = 8
  
  entry {
    cidr        = "99.153.67.104/29"
    description = "Austin Lab."
  }
  entry {
    cidr        = "18.203.31.30/32"
    description = "Ireland SD-WAN Hub 1"
  }
  entry {
    cidr        = "79.125.10.22/32"
    description = "Ireland SD-WAN Hub 2"
  }
  entry {
    cidr        = "57.182.142.140/32"
    description = "Tokyo SD-WAN Hub 1"
  }
  entry {
    cidr        = "57.181.146.34/32"
    description = "Tokyo SD-WAN Hub 2"
  }
  entry {
    cidr        = "192.168.0.0/16"
    description = "RFC1918"
  }
  entry {
    cidr        = "172.16.0.0/12"
    description = "RFC1918"
  }
  entry {
    cidr        = "10.0.0.0/8"
    description = "RFC1918"
  }
  
  tags = {
    Name = "panorama-allowed-prefix-list"
  }
}