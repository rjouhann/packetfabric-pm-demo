## General VARs
variable "tag_name" {
  default = "demo-pf"
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
variable "compartment_id" {
  type        = string
  description = "Oracle Parent Compartment OCID"
}

variable "oracle_region1" {
  type        = string
  default     = "us-sanjose-1"
  description = "Oracle Cloud region"
}

variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.6.1.0/24"
}