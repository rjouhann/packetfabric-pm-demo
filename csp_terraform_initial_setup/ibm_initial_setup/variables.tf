## General VARs
variable "tag_name" {
  default = "demo-pf"
}

## IBM VARs
variable "ibm_account_id" {
  type        = string
  sensitive   = true
  description = "IBM Account ID"
}
variable "ibmcloud_api_key" {
  type        = string
  sensitive   = true
  description = "IBM API key"
}
variable "iaas_classic_username" {
  type        = string
  sensitive   = true
  description = "IBM Classic Username"
}
variable "iaas_classic_api_key" {
  type        = string
  sensitive   = true
  description = "IBM Classic API key"
}

variable "ibm_region1" {
  type        = string
  default     = "us-south"
  description = "IBM Cloud region"
}
variable "ibm_region1_zone1" {
  type        = string
  description = "IBM Availability Zone"
  default     = "us-south-1"
}

variable "vpc_cidr1" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.7.0.0/16"
}

variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.7.1.0/24"
}