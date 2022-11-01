## General VARs
variable "tag_name" {
  default = "demo-pf-oracle"
}

## Oracle VARs
variable "tenancy_ocid" {
  type        = string
  sensitive   = true
  description = "Oracle Tenancy OCID"
}
variable "user_ocid" {
  type        = string
  sensitive   = true
  description = "Oracle User OCID"
}
variable "private_key" {
  type        = string
  sensitive   = true
  description = "Oracle Private Key"
}
# variable "private_key_password" {
#   type        = string
#   sensitive   = true
#   description = "Oracle Private Key Password"
# }
variable "fingerprint" {
  type        = string
  sensitive   = true
  description = "Oracle Public Key fingerprint"
}
variable "parent_compartment_id" {
  type        = string
  description = "Oracle Parent Compartment OCID"
}

variable "oracle_region1" {
  type        = string
  default     = "us-ashburn-1"
  description = "Oracle Cloud region"
}

variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.6.1.0/24"
}

variable "bandwidth_shape_name" {
  type    = string
  default = "1 Gbps"
}

# BGP peering
variable "peer_asn" {
  type    = number
  default = 64536 # private (64512 to 65534)
}
variable "primary_peer_address_prefix" {
  type    = string
  default = "169.254.247.41/30"
}
variable "secondary_peer_address_prefix" {
  type    = string
  default = "169.254.247.42/30"
}
variable "shared_key" {
  type      = string
  default   = "dd02c7c2232759874e1c20558" # echo "secret" | md5sum | cut -c1-25
  sensitive = true
}