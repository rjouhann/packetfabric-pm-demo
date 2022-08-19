## General VARs
variable "tag_name" {
  default = "demo-pf"
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

## PacketFabic VARs
variable "pf_api_key" {
  type        = string
  description = "PacketFabric platform API access key"
  sensitive   = true
}
variable "pf_account_uuid" {
  type = string
}
variable "pf_api_server" {
  type        = string
  default     = "https://api.packetfabric.com" # https://api.dev.packetfabric.net
  description = "PacketFabric API endpoint URL"
}
variable "pf_aws_account_id" {
  type = number
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
variable "pf_crc_speed" {
  type    = string
  default = "50Mbps"
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
variable "pf_crbs_orlonger" {
  type    = bool
  default = true # Allow longer prefixes
}