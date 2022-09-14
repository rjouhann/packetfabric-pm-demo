terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = ">= 0.2.1"
    }
  }
}

provider "packetfabric" {
  host  = var.pf_api_server
  token = var.pf_api_key
}

# Create random name to use to name objects
resource "random_pet" "name" {}

resource "packetfabric_cloud_router" "cr" {
  provider     = packetfabric
  asn          = var.pf_cr_asn
  name         = "${var.tag_name}-${random_pet.name.id}"
  account_uuid = var.pf_account_uuid
  capacity     = var.pf_cr_capacity
  regions      = var.pf_cr_regions
}

resource "packetfabric_aws_cloud_router_connection" "crc_1" {
  provider       = packetfabric
  description    = "${var.tag_name}-${random_pet.name.id}-${var.pf_crc_pop1}"
  circuit_id     = packetfabric_cloud_router.cr.id
  account_uuid   = var.pf_account_uuid
  aws_account_id = var.pf_aws_account_id
  pop            = var.pf_crc_pop1
  zone           = var.pf_crc_zone1
  speed          = var.pf_crc_speed
  maybe_nat      = var.pf_crc_maybe_nat
  is_public      = var.pf_crc_is_public
}