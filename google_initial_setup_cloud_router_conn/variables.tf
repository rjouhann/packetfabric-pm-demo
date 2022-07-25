## General VARs
variable "tag_name" {
  default = "demo-pf"
}

# GCO VARs
variable "gcp_project_id" {
  type        = string
  sensitive   = true
  description = "Google Cloud project ID"
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

# https://cloud.google.com/compute/docs/regions-zones
variable "gcp_region1" {
  type        = string
  default     = "us-west1"
  description = "Google Cloud region"
}

variable "gcp_zone1" {
  type        = string
  default     = "us-west1-a"
  description = "Google Cloud zone"
}

# VPC Variables
variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.5.1.0/24"
}
variable "subnet_cidr2" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.6.1.0/24"
}
variable "public_key" {
  sensitive = true
}