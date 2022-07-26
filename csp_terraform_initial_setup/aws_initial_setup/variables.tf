## General VARs
variable "tag_name" {
  default = "demo-pf"
}

## AWS VARs
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
variable "aws_region1" {
  type        = string
  description = "AWS region"
  default     = "us-west-2" # us-west-2, eu-west-2
}
variable "aws_region1_zone1" {
  type        = string
  description = "AWS Availability Zone"
  default     = "us-west-2a"
}
variable "aws_region2" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}
variable "aws_region2_zone1" {
  type        = string
  description = "AWS Availability Zone"
  default     = "us-east-1a"
}
variable "vpc_cidr1" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.0.0/16"
}
variable "subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.1.1.0/24"
}
variable "vpc_cidr2" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.2.0.0/16"
}
variable "subnet_cidr2" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.2.1.0/24"
}
variable "ec2_ami1" {
  default = "ami-0d70546e43a941d70" # Ubuntu 22.04 in aws_region1 (us-west-2 ami-0d70546e43a941d70, eu-west-2 ami-0fb391cce7a602d1f)
}
variable "ec2_ami2" {
  default = "ami-052efd3df9dad4825" # Ubuntu 22.04 in aws_region2
}
variable "ec2_instance_type" {
  default = "t2.micro" # Free tier
}
variable "public_key" {
  sensitive = true
}