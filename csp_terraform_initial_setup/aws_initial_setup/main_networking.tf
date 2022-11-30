terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
  }
}

# Define default profile
provider "aws" {
  region     = var.aws_region1
}
# Profile for Region1
provider "aws" {
  region     = var.aws_region1
  alias      = "region1"
}
# Profile for Region2
provider "aws" {
  region     = var.aws_region2
  alias      = "region2"
}

# create random name to use to name objects
resource "random_pet" "name" {}

# Create the VPCs
resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpc_cidr1
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_vpc" "vpc_2" {
  provider             = aws.region2
  cidr_block           = var.vpc_cidr2
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Define the public subnets
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.vpc_1.id
  availability_zone = var.aws_region1_zone1
  cidr_block        = var.subnet_cidr1
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_subnet" "subnet_2" {
  provider          = aws.region2
  vpc_id            = aws_vpc.vpc_2.id
  availability_zone = var.aws_region2_zone1
  cidr_block        = var.subnet_cidr2
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Define the internet gateways
resource "aws_internet_gateway" "gw_1" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_internet_gateway" "gw_2" {
  provider = aws.region2
  vpc_id   = aws_vpc.vpc_2.id
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

## Transit Gateway (creation + attachement to the VPC)
# resource "aws_ec2_transit_gateway" "transit_gw_1" {
#   amazon_side_asn = var.amazon_side_asn1
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# resource "aws_ec2_transit_gateway" "transit_gw_2" {
#   provider = aws.region2
#   amazon_side_asn = var.amazon_side_asn2
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gw_to_vpc_1" {
#   subnet_ids         = [aws_subnet.subnet_1.id]
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gw_1.id
#   vpc_id             = aws_vpc.vpc_1.id
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gw_to_vpc_2" {
#   provider = aws.region2
#   subnet_ids         = [aws_subnet.subnet_2.id]
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gw_2.id
#   vpc_id             = aws_vpc.vpc_2.id
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # Virtual Private Gateway (creation + attachement to the VPC)
# resource "aws_vpn_gateway" "vpn_gw_1" {
#   vpc_id = aws_vpc.vpc_1.id
#   amazon_side_asn = var.amazon_side_asn1
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_vpn_gateway" "vpn_gw_2" {
#   provider = aws.region2
#   vpc_id = aws_vpc.vpc_2.id
#   amazon_side_asn = var.amazon_side_asn2
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# Virtual Private Gateway (creation + attachement to the VPC)
resource "aws_vpn_gateway" "vpn_gw_1" {
  provider        = aws
  amazon_side_asn = var.amazon_side_asn1
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
  depends_on = [
    aws_vpc.vpc_1
  ]
}
resource "aws_vpn_gateway_attachment" "vpn_attachment_1" {
  provider       = aws
  vpc_id         = aws_vpc.vpc_1.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_1.id
}
resource "aws_vpn_gateway" "vpn_gw_2" {
  provider        = aws.region2
  amazon_side_asn = var.amazon_side_asn2
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
  depends_on = [
    aws_vpc.vpc_2
  ]
}
resource "aws_vpn_gateway_attachment" "vpn_attachment_2" {
  provider       = aws.region2
  vpc_id         = aws_vpc.vpc_2.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_2.id
}

# Define the route tables
resource "aws_route_table" "route_table_1" {
  vpc_id = aws_vpc.vpc_1.id
  # internet gw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_1.id
  }
  # virtual private gw
  # route {
  #   cidr_block = var.subnet_cidr2
  #   gateway_id = aws_vpn_gateway.vpn_gw_1.id
  # }
  propagating_vgws = ["${aws_vpn_gateway.vpn_gw_1.id}"]
  # # transite gw
  # route {
  #   cidr_block = var.subnet_cidr1
  #   gateway_id = aws_ec2_transit_gateway.transit_gw_1.id
  # }
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_route_table" "route_table_2" {
  provider = aws.region2
  vpc_id   = aws_vpc.vpc_2.id
  # internet gw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_2.id
  }
  # virtual private gw
  # route {
  #   cidr_block = var.subnet_cidr1
  #   gateway_id = aws_vpn_gateway.vpn_gw_2.id
  # }
  propagating_vgws = ["${aws_vpn_gateway.vpn_gw_2.id}"]
  # # transite gw
  # route {
  #   cidr_block = var.subnet_cidr1
  #   gateway_id = aws_ec2_transit_gateway.transit_gw_2.id
  # }
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Assign the route table to the public subnet
resource "aws_route_table_association" "route_association_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table_1.id
}
resource "aws_route_table_association" "route_association_2" {
  provider       = aws.region2
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.route_table_2.id
}

output "aws_vpn_gateway_1" {
  description = "Virtual Private Gateway ID for Region 1"
  value       = aws_vpn_gateway.vpn_gw_1.id
}

output "aws_vpn_gateway_2" {
  description = "Virtual Private Gateway ID for Region 2"
  value       = aws_vpn_gateway.vpn_gw_2.id
}




