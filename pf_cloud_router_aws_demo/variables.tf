## General VARs
variable "tag_name" {
  default = "DEMO-PF"
}

# AWS VARs
variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}
# https://aws.amazon.com/directconnect/locations/
variable "aws_region1" {
  type        = string
  description = "AWS region"
  default     = "us-west-2" # us-west-2, eu-west-2
}
variable "aws_region2" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}
# variable "aws_transit_gateway1" {
#   type        = string
#   description = "AWS Transit Gateway ID Region 1"
# }
# variable "aws_transit_gateway2" {
#   type        = string
#   description = "AWS Transit Gateway ID Region 2"
# }
variable "aws_virtual_private_gateway1" {
  type        = string
  description = "AWS Virtual Private Gateway ID Region 1"
}
variable "aws_virtual_private_gateway2" {
  type        = string
  description = "AWS Virtual Private Gateway ID Region 2"
}


## PacketFabic VARs
variable "pf_api_key" {
  type        = string
  description = "PacketFabric platform API access key"
  sensitive   = true
}
variable "pf_account_uuid" {
  type = string
}
variable "pf_aws_account_id" {
  type = number
}
variable "pf_api_server" {
  type        = string
  default     = "https://api.packetfabric.com" # https://api.dev.packetfabric.net
  description = "PacketFabric API endpoint URL"
}
variable "pf_provider_source" {
  type    = string
  default = "packetfabric/packetfabric"
}
# PacketFabric Cloud-Router Parameter configurations
variable "pf_cr_asn" {
  type     = number
  default  = 4556 # PacketFabric ASN
  nullable = false
}
# Parameter deprecated
variable "pf_cr_scope" {
  type    = string
  default = "private"
}
variable "pf_cr_capacity" {
  type    = string
  default = "1Gbps" # 2Gbps
}
variable "pf_cr_regions" {
  type    = list(string)
  default = ["US"] # ["US"] or ["US", "UK"] or ["UK"]
}

# PacketFabric Cloud-Router-Connections Parameter configuration:
variable "pf_crc_pop1" {
  type    = string
  default = "PDX2" # PDX2/a LAX1/c SF06/a LON1/a
}
variable "pf_crc_zone1" {
  type    = string
  default = "a"
}
variable "pf_crc_pop2" {
  type    = string
  default = "NYC1" # NYC1/c WDC2/e
}
variable "pf_crc_zone2" {
  type    = string
  default = "c"
}
variable "pf_crc_speed" {
  type    = string
  default = "50Mbps" #  # 1Gbps min for Transit Gateway
}
variable "pf_crc_maybe_nat" {
  type    = bool
  default = false
}
variable "pf_crc_is_public" {
  type    = bool
  default = false
}

# PacketFabric Cloud-Router-BGP-Session Parameter configuration:
variable "pf_crbs_af" {
  type    = string
  default = "v4"
}
variable "pf_crbs_mhttl" {
  type    = number
  default = 1
}
variable "amazon_side_asn1" {
  type     = number
  default  = 64512 # private
  nullable = false
}
variable "amazon_side_asn2" {
  type     = number
  default  = 64513 # private
  nullable = false
}
variable "pf_crbs_orlonger" {
  type    = bool
  default = true # Allow longer prefixes
}

# PacketFabric Cloud-Router-BGP-Prefixes Parameter configuration:
variable "vpc_cidr1" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.0.0/16"
}
# VPC Variables
variable "vpc_cidr2" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.2.0.0/16"
}

# PacketFabric Interface Parameter configuration:
variable "pf_cs_interface_media" {
  type    = string
  default = "LX"
}
variable "pf_cs_interface_avzone" {
  type    = string
  default = "A"
}
variable "pf_cs_interface_pop" {
  type    = string
  default = "PDX1"
}
variable "pf_cs_interface_subterm" {
  type    = number
  default = 1
}
variable "pf_cs_interface_srvclass" {
  type    = string
  default = "metro"
}
variable "pf_cs_interface_autoneg" {
  type    = bool
  default = false
}
variable "pf_cs_interface_speed" {
  type    = string
  default = "1Gbps"
}
variable "pf_cs_interface_nni" {
  type    = bool
  default = false
}
