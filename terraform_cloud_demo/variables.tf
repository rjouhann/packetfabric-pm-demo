## General VARs
variable "tag_name" {
  default = "demo-terraform"
}

## PacketFabic VARs
variable "pf_api_key" {
  type        = string
  description = "PacketFabric platform API access key"
  default     = "secret"
  sensitive   = true
}
variable "pf_account_uuid" {
  type      = string
  default   = "secret"
  sensitive = true
}
variable "pf_api_server" {
  type        = string
  default     = "https://api.packetfabric.com"
  description = "PacketFabric API endpoint URL"
}

variable "pf_cr_asn" {
  type     = number
  default  = 4556 # PacketFabric ASN
  nullable = false
}
variable "pf_cr_capacity" {
  type    = string
  default = "1Gbps" # 2Gbps
}
variable "pf_cr_regions" {
  type    = list(string)
  default = ["US"] # ["US"] or ["US", "UK"] or ["UK"]
}
variable "pf_aws_account_id" {
  type    = string
  default = "123456789"
}
variable "pf_crc_speed" {
  type    = string
  default = "50Mbps"
}
variable "pf_crc_pop1" {
  type    = string
  default = "PDX2" # PDX2/a LAX1/c SF06/a LON1/a
}
variable "pf_crc_zone1" {
  type    = string
  default = "a"
}
variable "pf_crc_maybe_nat" {
  type    = bool
  default = false
}
variable "pf_crc_is_public" {
  type    = bool
  default = false
}
