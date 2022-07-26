terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = "0.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.29.0"
    }
  }
}

provider "packetfabric" {
  host  = var.pf_api_server
  token = var.pf_api_key
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region1
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "google" {
  project     = var.gcp_project_id
  credentials = file(var.gcp_credentials)
  region      = var.gcp_region1
  zone        = var.gcp_zone1
}

# Create random name to use to name objects
resource "random_pet" "name" {}

# # From the PacketFabric side: Create a PacketFabric interface
# resource "packetfabric_interface" "port_1" {
#   provider = packetfabric
#   account_uuid = var.pf_account_uuid
#   autoneg = var.pf_cs_interface_autoneg
#   description = "${var.tag_name}-${random_pet.name.id}"
#   media = var.pf_cs_interface_media
#   nni = var.pf_cs_interface_nni
#   pop = var.pf_cs_interface_pop
#   speed = var.pf_cs_interface_speed
#   subscription_term = var.pf_cs_interface_subterm
#   zone = var.pf_cs_interface_avzone
# }
# output "packetfabric_interface" {
#   value = packetfabric_interface.port_1
# }

# From the PacketFabric side: Create a cloud router
resource "packetfabric_cloud_router" "cr" {
  provider     = packetfabric
  # scope        = var.pf_cr_scope # Parameter deprecated
  asn          = var.pf_cr_asn
  name         = "${var.tag_name}-${random_pet.name.id}"
  account_uuid = var.pf_account_uuid
  capacity     = var.pf_cr_capacity
  regions      = var.pf_cr_regions
}

data "packetfabric_cloud_router" "current" {
  provider = packetfabric
  depends_on = [
    cloud_router.cr
  ]
}
output "packetfabric_cloud_router" {
  value = data.packetfabric_cloud_router.current
}

# From the PacketFabric side: Create a cloud router connection to Dedicated Port

####### not available yet in 0.1.0


# From the PacketFabric side: Create a cloud router connection to AWS
resource "packetfabric_aws_cloud_router_connection" "crc_1" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  account_uuid   = var.pf_account_uuid
  aws_account_id = var.pf_aws_account_id
  maybe_nat      = var.pf_crc_maybe_nat
  description    = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  pop            = var.pf_crc_pop1
  zone           = var.pf_crc_zone1
  is_public      = var.pf_crc_is_public
  speed          = var.pf_crc_speed
  lifecycle {
    ignore_changes = [
      circuit_id,
      description,
      pop,
      zone
    ]
  }
}
resource "packetfabric_aws_cloud_router_connection" "crc_2" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  account_uuid   = var.pf_account_uuid
  aws_account_id = var.pf_aws_account_id
  maybe_nat      = var.pf_crc_maybe_nat
  description    = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop2}"
  pop            = var.pf_crc_pop2
  zone           = var.pf_crc_zone2
  is_public      = var.pf_crc_is_public
  speed          = var.pf_crc_speed
  lifecycle {
    ignore_changes = [
      circuit_id,
      description,
      pop,
      zone
    ]
  }
}

# Wait 30s for the connection to show up in AWS
resource "null_resource" "previous" {}
resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "30s"
}
# This resource will create (at least) 30 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_30_seconds]
}

# Retrieve the Direct Connect connection in AWS
data "aws_dx_connection" "current_1" {
  provider = aws
  name     = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  depends_on = [
    null_resource.next
  ]
}
# From the AWS side: Accept the connection
resource "aws_dx_connection_confirmation" "confirmation_1" {
  provider      = aws
  connection_id = data.aws_dx_connection.current_1.id
}

# From the AWS side: Create a gateway
resource "aws_dx_gateway" "direct_connect_gw_1" {
  provider        = aws
  name            = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  amazon_side_asn = var.amazon_side_asn1
  depends_on = [
    packetfabric_aws_cloud_router_connection.crc_1
  ]
}

# From the AWS side: Create and attach a VIF
# https://github.com/PacketFabric/terraform-provider-packetfabric/issues/23
# data "packetfabric_aws_cloud_router_connection" "current_1" {
#   provider   = packetfabric
#   circuit_id = packetfabric_aws_cloud_router_connection.crc_1.id

#   depends_on = [
#     aws_dx_connection_confirmation.confirmation_1
#   ]
# }
# output "packetfabric_aws_cloud_router_connection_1" {
#   value = data.packetfabric_aws_cloud_router_connection.current_1 #.aws_cloud_connections[*]
# }
# data "packetfabric_aws_cloud_router_connection" "current_2" {
#   provider   = packetfabric
#   circuit_id = packetfabric_aws_cloud_router_connection.crc_2.id

#   depends_on = [
#     aws_dx_connection_confirmation.confirmation_2
#   ]
# }
# output "packetfabric_aws_cloud_router_connection_2" {
#   value = data.packetfabric_aws_cloud_router_connection.current_2 
# }

# Workaround
data "packetfabric_aws_cloud_router_connection" "current" {
  provider   = packetfabric
  circuit_id = cloud_router.cr.id

  depends_on = [
    aws_dx_connection_confirmation.confirmation_1,
    aws_dx_connection_confirmation.confirmation_2,
  ]
}
locals {
  aws_cloud_connections = data.packetfabric_aws_cloud_router_connection.current.aws_cloud_connections[*]
  helper_map = {for val in local.aws_cloud_connections:
              val["description"]=>val}
  cc1 = local.helper_map["${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"]
}
output "cc1_vlan_id_pf" {
    value = one(local.cc1.cloud_settings[*].vlan_id_pf)
}
output "packetfabric_aws_cloud_router_connection" {
  value = data.packetfabric_aws_cloud_router_connection.current.aws_cloud_connections[*]
}
resource "aws_dx_private_virtual_interface" "direct_connect_vip_1" {
  provider       = aws
  connection_id  = data.aws_dx_connection.current_1.id
  dx_gateway_id  = aws_dx_gateway.direct_connect_gw_1.id 
  name           = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  vlan           = one(local.cc1.cloud_settings[*].vlan_id_pf)
  address_family = "ipv4"
  bgp_asn        = var.pf_cr_asn
  depends_on = [
    #data.packetfabric_aws_cloud_router_connection.current_1
    data.packetfabric_aws_cloud_router_connection.current
  ]
}

# From the AWS side: Associate Virtual Private GW  or Transit GW to Direct Connect GW
resource "aws_dx_gateway_association" "virtual_private_gw_to_direct_connect_1" {
  provider       = aws.region1
  dx_gateway_id         = aws_dx_gateway.direct_connect_gw_1.id
  associated_gateway_id = var.aws_virtual_private_gateway1
  allowed_prefixes = [
    var.vpc_cidr1,
    var.vpc_cidr2
  ]
  depends_on = [
    aws_dx_private_virtual_interface.direct_connect_vip_1
  ]
  timeouts {
    create = "1h"
    delete = "2h"
  }
}

# From the PacketFabric side: Configure BGP
resource "packetfabric_cloud_router_bgp_session" "crbs_1" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  connection_id  = packetfabric_aws_cloud_router_connection.crc_1.id
  address_family = var.pf_crbs_af
  multihop_ttl   = var.pf_crbs_mhttl
  remote_asn     = var.amazon_side_asn1
  orlonger       = var.pf_crbs_orlonger
  remote_address = aws_dx_private_virtual_interface.direct_connect_vip_1.amazon_address # AWS side
  l3_address     = aws_dx_private_virtual_interface.direct_connect_vip_1.customer_address # PF side
  md5            = aws_dx_private_virtual_interface.direct_connect_vip_1.bgp_auth_key
}
resource "packetfabric_cloud_router_bgp_prefixes" "crbp_1" {
  provider = packetfabric
  bgp_settings_uuid = packetfabric_cloud_router_bgp_session.crbs_1.id
  prefixes {
    prefix = var.vpc_cidr2
    type = "out" # Allowed Prefixes to Cloud
    order = 0
  }
  prefixes {
    prefix = var.vpc_cidr1
    type = "in" # Allowed Prefixes from Cloud
    order = 0
  }
}

resource "packetfabric_cloud_router_bgp_session" "crbs_2" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  connection_id  = packetfabric_aws_cloud_router_connection.crc_2.id
  address_family = var.pf_crbs_af
  multihop_ttl   = var.pf_crbs_mhttl
  remote_asn     = var.amazon_side_asn2
  orlonger       = var.pf_crbs_orlonger
  remote_address = aws_dx_private_virtual_interface.direct_connect_vip_2.amazon_address # AWS side
  l3_address     = aws_dx_private_virtual_interface.direct_connect_vip_2.customer_address # PF side
  md5            = aws_dx_private_virtual_interface.direct_connect_vip_2.bgp_auth_key
}
resource "packetfabric_cloud_router_bgp_prefixes" "crbp_2" {
  provider = packetfabric
  bgp_settings_uuid = packetfabric_cloud_router_bgp_session.crbs_2.id
  prefixes {
    prefix = var.vpc_cidr1
    type = "out" # Allowed Prefixes to Cloud
    order = 0
  }
  prefixes {
    prefix = var.vpc_cidr2
    type = "in" # Allowed Prefixes from Cloud
    order = 0
  }
}
