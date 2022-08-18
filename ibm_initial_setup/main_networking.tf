terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.45.0-beta0"
    }
  }
}

provider "ibm" {
  region                = var.ibm_region1
  ibmcloud_api_key      = var.ibmcloud_api_key
  iaas_classic_username = var.iaas_classic_username
  iaas_classic_api_key  = var.iaas_classic_api_key
}

# create random name to use to name objects
resource "random_pet" "name" {}

resource "ibm_resource_group" "resource_group_1" {
  name = "${var.tag_name}-${random_pet.name.id}"
}

resource "ibm_is_vpc" "vpc_1" {
  name           = "${var.tag_name}-${random_pet.name.id}"
  resource_group = ibm_resource_group.resource_group_1.id
  address_prefix_management = "manual" # no default prefix will be created for each zone in this VPC.
}

resource "ibm_is_vpc_address_prefix" "vpc_prefix_1" {
  name = "${var.tag_name}-${random_pet.name.id}"
  zone = var.ibm_region1_zone1
  vpc  = ibm_is_vpc.vpc_1.id
  cidr = var.vpc_cidr1
}

resource "ibm_is_subnet" "subnet_1" {
  name            = "${var.tag_name}-${random_pet.name.id}"
  resource_group  = ibm_resource_group.resource_group_1.id
  vpc             = ibm_is_vpc.vpc_1.id
  zone            = var.ibm_region1_zone1
  ipv4_cidr_block = var.subnet_cidr1
  #routing_table   = ibm_is_vpc_routing_table.example.routing_table
}

data "ibm_is_subnet" "subnet_1" {
  identifier = ibm_is_subnet.subnet_1.id
}

output "ibm_is_subnet" {
  value = data.ibm_is_subnet.subnet_1
}

# data "ibm_dl_gateway" "direct_link_gw" {
#     name = "${var.tag_name}-${random_pet.name.id}"
# }

# output "ibm_dl_gateway" {
#   value = data.ibm_dl_gateway.direct_link_gw
# }
