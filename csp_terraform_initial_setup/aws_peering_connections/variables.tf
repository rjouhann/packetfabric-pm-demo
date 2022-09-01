## General VARs
variable "tag_name" {
  default = "demo-pf"
}

## AWS VARs
variable "aws_region1" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}
variable "aws_region2" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}
# VPC Variables
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