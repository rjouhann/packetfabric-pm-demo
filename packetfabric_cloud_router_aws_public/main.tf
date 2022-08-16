terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = "0.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
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

# From the PacketFabric side: Create a cloud router
resource "cloud_router" "cr" {
  provider     = packetfabric
  scope        = var.pf_cr_scope # Parameter deprecated
  asn          = var.pf_cr_asn
  name         = "${var.tag_name}-${random_pet.name.id}"
  account_uuid = var.pf_account_uuid
  capacity     = var.pf_cr_capacity
  regions      = var.pf_cr_regions
}

data "cloud_router" "current" {
  provider = packetfabric
  depends_on = [
    cloud_router.cr
  ]
}
output "cloud_router" {
  value = data.cloud_router.current
}

# From the PacketFabric side: Create a cloud router connection to AWS
resource "aws_cloud_router_connection" "crc_1" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  account_uuid   = var.pf_account_uuid
  aws_account_id = var.pf_aws_account_id
  maybe_nat      = true
  description    = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  pop            = var.pf_crc_pop1
  zone           = var.pf_crc_zone1
  is_public      = true
  speed          = var.pf_crc_speed
}

# Wait 60s for the connection to show up in AWS
resource "null_resource" "previous" {}
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}
# This resource will create (at least) 60 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_60_seconds]
}

# Retrieve the Direct Connect connections in AWS
data "aws_dx_connection" "current_1" {
  provider = aws
  name     = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  depends_on = [
    null_resource.next,
    aws_cloud_router_connection.crc_1
  ]
}
output "aws_dx_connection_1" {
  value = data.aws_dx_connection.current_1
}

resource "aws_dx_connection_confirmation" "confirmation_1" {
  provider      = aws
  connection_id = data.aws_dx_connection.current_1.id
}

# From the AWS side: Create and attach a VIF

### see issue https://github.com/hashicorp/terraform-provider-aws/issues/25989

############# OPTION 1
data "aws_cloud_router_connection" "current" {
  provider   = packetfabric
  circuit_id = cloud_router.cr.id

  depends_on = [
    aws_dx_connection_confirmation.confirmation_1
  ]
}
locals {
  cloud_connections = data.aws_cloud_router_connection.current.cloud_connections[*]
  helper_map = { for val in local.cloud_connections :
  val["description"] => val }
  cc1 = local.helper_map["${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"]

  cc1_vlan_id_pf = one(local.cc1.cloud_settings[*].vlan_id_pf)
  # Public AWS Router Peer IP
  cc1_public_ip = "${cidrhost(one(local.cc1.cloud_settings[*].public_ip), 0)}/${element(split("/", "${one(local.cc1.cloud_settings[*].public_ip)}"), 1)}"
  # PacketFabric Router Peer IP
  cc1_customer_address = "${cidrhost(one(local.cc1.cloud_settings[*].public_ip), 1)}/${element(split("/", "${one(local.cc1.cloud_settings[*].public_ip)}"), 1)}"
  # PacketFabric router prefix with /32
  cc1_nat_public_ip = one(local.cc1.cloud_settings[*].nat_public_ip)
}

output "cc1_vlan_id_pf" {
  value = local.cc1_vlan_id_pf
}
output "cc1_public_ip" {
  value = local.cc1_public_ip
}
output "cc1_customer_address" {
  value = local.cc1_customer_address
}
output "cc1_nat_public_ip" {
  value = local.cc1_nat_public_ip
}

output "aws_cloud_router_connection" {
  value = data.aws_cloud_router_connection.current.aws_cloud_connections[*]
}

resource "aws_dx_public_virtual_interface" "direct_connect_vif_1" {
  provider         = aws
  name             = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  connection_id    = data.aws_dx_connection.current_1.id
  bgp_asn          = var.pf_cr_asn
  vlan             = local.cc1_vlan_id_pf
  address_family   = "ipv4"
  amazon_address   = local.cc1_public_ip
  customer_address = local.cc1_customer_address

  route_filter_prefixes = [
    local.cc1_public_ip,
    local.cc1_nat_public_ip
  ]
  depends_on = [
    aws_dx_connection_confirmation.confirmation_1,
    data.aws_cloud_router_connection.current
  ]
  lifecycle {
    ignore_changes = [
      vlan
    ]
  }
}

############# OPTION 2
# module "aws_dx_public_vif" {
#   source = "./modules/aws_dx_public_vif"
#   pf_api_server  = var.pf_api_server
#   pf_api_key = var.pf_api_key
#   crc_name = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
#   cloud_router_circuit_id = cloud_router.cr.id
# }

# output "cc1_vlan_id_pf" {
#   value = module.aws_dx_public_vif.cc1_vlan_id_pf
# }
# output "cc1_public_ip" {
#   value = module.aws_dx_public_vif.cc1_public_ip
# }
# output "cc1_customer_address" {
#   value = module.aws_dx_public_vif.cc1_customer_address
# }

# resource "aws_dx_public_virtual_interface" "direct_connect_vif_1" {
#   provider         = aws
#   name             = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
#   connection_id    = data.aws_dx_connection.current_1.id
#   bgp_asn          = var.pf_cr_asn
#   vlan             = module.aws_dx_public_vif.cc1_vlan_id_pf
#   address_family   = "ipv4"
#   amazon_address   = module.aws_dx_public_vif.cc1_public_ip        # Public AWS Router Peer IP
#   customer_address = module.aws_dx_public_vif.cc1_customer_address # PacketFabric Router Peer IP

#   route_filter_prefixes = [
#     "${module.aws_dx_public_vif.cc1_public_ip}"
#     # Add any addition public IPs if needed
#   ]
#   depends_on = [
#     module.aws_dx_public_vif
#   ]
#   lifecycle {
#     ignore_changes = [
#       vlan
#     ]
#   }
# }
#############

# # From the PacketFabric side: Configure BGP
resource "cloud_router_bgp_session" "crbs_1" {
  provider       = packetfabric
  circuit_id     = cloud_router.cr.id
  connection_id  = aws_cloud_router_connection.crc_1.id
  address_family = var.pf_crbs_af
  multihop_ttl   = var.pf_crbs_mhttl
  remote_asn     = var.amazon_side_asn1
  orlonger       = var.pf_crbs_orlonger
  remote_address = aws_dx_public_virtual_interface.direct_connect_vif_1.amazon_address   # AWS side
  l3_address     = aws_dx_public_virtual_interface.direct_connect_vif_1.customer_address # PF side
  md5            = aws_dx_public_virtual_interface.direct_connect_vif_1.bgp_auth_key
  # The prefixes from the cloud that you want to associate with the NAT pool.
  # pool_prefixes = [ prefix_from_azure, prefix_from_google ] # to update with correct VNET/VPC from those 2 clouds
  # If this connection uses a public IP address, then this field is autofilled with the PacketFabric router prefix with /32
  pre_nat_sources = local.cc1_nat_public_ip
}
resource "cloud_router_bgp_prefixes" "crbp_1" {
  provider          = packetfabric
  bgp_settings_uuid = cloud_router_bgp_session.crbs_1.id
  prefixes {
    prefix = aws_dx_public_virtual_interface.direct_connect_vif_1.amazon_address
    type   = "out" # Allowed Prefixes to Cloud
    order  = 0
  }
  prefixes {
    prefix = local.cc1_nat_public_ip
    type   = "out" # Allowed Prefixes to Cloud
    order  = 1
  }
  prefixes {
    prefix = "0.0.0.0/0"
    type   = "in" # Allowed Prefixes from Cloud
    order  = 0
  }
}

## Display warning for Amazon Public VIF
## NOTE: Public VIFs must be reviewed and approved by Amazon. This process can take up to 72 hours.
