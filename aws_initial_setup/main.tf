terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

# Define default profile
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region1
  profile    = "region1-profile"
}
# Profile for Region1
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region1
  profile    = "region1-profile"
  alias      = "region1"
}
# Profile for Region2
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region2
  profile    = "region2-profile"
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

resource "aws_security_group" "ingress_all_1" {
  name   = "allow-icmp-ssh-http-locust-iperf-sg"
  vpc_id = aws_vpc.vpc_1.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_security_group" "ingress_all_2" {
  provider = aws.region2
  name     = "allow-icmp-ssh-http-locust-iperf-sg"
  vpc_id   = aws_vpc.vpc_2.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Create NIC for the EC2 instances
resource "aws_network_interface" "nic1" {
  subnet_id       = aws_subnet.subnet_1.id
  security_groups = ["${aws_security_group.ingress_all_1.id}"]
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_network_interface" "nic2" {
  provider        = aws.region2
  subnet_id       = aws_subnet.subnet_2.id
  security_groups = ["${aws_security_group.ingress_all_2.id}"]
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Create the Key Pair
resource "aws_key_pair" "ssh_key_1" {
  key_name   = "ssh_key-${random_pet.name.id}"
  public_key = var.public_key
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_key_pair" "ssh_key_2" {
  provider   = aws.region2
  key_name   = "ssh_key-${random_pet.name.id}"
  public_key = var.public_key
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Create the Ubuntu EC2 instances
resource "aws_instance" "ec2_instance_1" {
  ami           = var.ec2_ami1
  instance_type = var.ec2_instance_type
  network_interface {
    network_interface_id = aws_network_interface.nic1.id
    device_index         = 0
  }
  key_name  = aws_key_pair.ssh_key_1.id
  user_data = file("../user-data-ubuntu.sh")
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_instance" "ec2_instance_2" {
  provider      = aws.region2
  ami           = var.ec2_ami2
  instance_type = var.ec2_instance_type
  network_interface {
    network_interface_id = aws_network_interface.nic2.id
    device_index         = 0
  }
  key_name  = aws_key_pair.ssh_key_2.id
  user_data = file("../user-data-ubuntu.sh")
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# Assign a public IP to both EC2 instances
resource "aws_eip" "public_ip_1" {
  instance = aws_instance.ec2_instance_1.id
  vpc      = true
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}
resource "aws_eip" "public_ip_2" {
  provider = aws.region2
  instance = aws_instance.ec2_instance_2.id
  vpc      = true
  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

# output "aws_ec2_transit_gateway_1" {
#   description = "Transit Gateway ID for Region 1"
#   value = aws_ec2_transit_gateway.transit_gw_1.id
# }

# output "aws_ec2_transit_gateway_2" {
#   description = "Transit Gateway ID for Region 2"
#   value = aws_ec2_transit_gateway.transit_gw_2.id
# }

output "aws_vpn_gateway_1" {
  description = "Virtual Private Gateway ID for Region 1"
  value       = aws_vpn_gateway.vpn_gw_1.id
}

output "aws_vpn_gateway_2" {
  description = "Virtual Private Gateway ID for Region 2"
  value       = aws_vpn_gateway.vpn_gw_2.id
}

# Private IPs of the demo Ubuntu instances
output "ec2_private_ip_1" {
  description = "Private ip address for EC2 instance for Region 1"
  value       = aws_instance.ec2_instance_1.private_ip
}

output "ec2_private_ip_2" {
  description = "Private ip address for EC2 instance for Region 2"
  value       = aws_instance.ec2_instance_2.private_ip
}

# Public IPs of the demo Ubuntu instances
output "ec2_public_ip_1" {
  description = "Elastic ip address for EC2 instance for Region 1"
  value       = aws_eip.public_ip_1.public_ip
}

output "ec2_public_ip_2" {
  description = "Elastic ip address for EC2 instance for Region 2"
  value       = aws_eip.public_ip_2.public_ip
}



