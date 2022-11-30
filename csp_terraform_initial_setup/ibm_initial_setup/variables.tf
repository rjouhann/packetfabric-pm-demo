## General VARs
variable "tag_name" {
  default = "demo-pf"
}

## IBM VARs
variable "ibm_ressource_group" {
  type        = string
  sensitive   = true
  description = "IBM Resource Group to use"
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