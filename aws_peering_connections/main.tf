terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
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

data "aws_vpc" "vcp_current_1" {
  cidr_block   = var.vpc_cidr1
}

data "aws_vpc" "vcp_current_2" {
  provider = aws.region2
  cidr_block   = var.vpc_cidr2
}

resource "aws_vpc_peering_connection" "main" {
  vpc_id        = data.aws_vpc.vcp_current_1.id
  peer_vpc_id   = data.aws_vpc.vcp_current_2.id
  peer_region   = var.aws_region2

  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = true

  tags = {
    Name = "${var.tag_name}-${random_pet.name.id}"
  }
}

data "aws_route_table" "route_table_current_1" {
  vpc_id        = data.aws_vpc.vcp_current_1.id
  filter {
    name   = "association.main"
    values = ["false"]
  }
}

data "aws_route_table" "route_table_current_2" {
  provider = aws.region2
  vpc_id   = data.aws_vpc.vcp_current_2.id
  filter {
    name   = "association.main"
    values = ["false"]
  }
}

resource "aws_route" "route_table_1" {
  route_table_id            = data.aws_route_table.route_table_current_1.id
  destination_cidr_block    = var.vpc_cidr2
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "route_table_2" {
  provider = aws.region2
  route_table_id            = data.aws_route_table.route_table_current_2.id
  destination_cidr_block    = var.vpc_cidr1
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}