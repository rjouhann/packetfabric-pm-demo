## General VARs
variable "tag_name" {
  default = "demo-pf"
}

## Azure VARs
# https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
variable "azure_region1" {
  type        = string
  description = "Azure region"
  default     = "East US"
}
variable "azure_region2" {
  type        = string
  description = "Azure region"
  default     = "West US"
}
# https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers
# West US (Silicon Valley)
# West Central US (Denver)
# North Central US (Chicago)
# East US, East US2 (New York, Washington DC)
# South Central US (Dallas)
# Las Vegas
variable "peering_location_1" {
  type        = string
  description = "Azure Peering Location"
  default     = "New York"
}
variable "peering_location_2" {
  type        = string
  description = "Azure Peering Location"
  default     = "Silicon Valley"
}
variable "bandwidth_in_mbps" {
  type        = string
  description = "Azure Bandwidth"
  default     = 50
}
variable "service_provider_name" {
  type    = string
  default = "PacketFabric"
}
variable "sku_tier" {
  type    = string
  default = "Standard" # Standard or Premium
}
variable "sku_family" {
  type    = string
  default = "MeteredData"
}

# Express Route GW SKUs ErGw1AZ, ErGw2AZ, ErGw3AZ
variable "vnet_cidr1" {
  type        = string
  description = "CIDR for the VNET"
  default     = "10.3.0.0/16"
}
variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.3.1.0/24"
}
variable "subnet_cidr1gw" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.3.2.0/24"
}
variable "public_key" {
  sensitive = true
}
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  sensitive   = true
}
variable "client_id" {
  type        = string
  description = "Azure Client ID"
  sensitive   = true
}
variable "client_secret" {
  type        = string
  description = "Azure Client Secret ID"
  sensitive   = true
}
variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  sensitive   = true
}