terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = "0.2.0"
    }
  }
}

provider "packetfabric" {
  host  = var.pf_api_server
  token = var.pf_api_key
}

# Create random name to use to name objects
resource "random_pet" "name" {}

# From the PacketFabric side: Create a cloud router
resource "packetfabric_cloud_router" "cr" {
  provider     = packetfabric
  scope        = var.pf_cr_scope
  asn          = var.pf_cr_asn
  name         = "${var.tag_name}-${random_pet.name.id}"
  account_uuid = var.pf_account_uuid
  capacity     = var.pf_cr_capacity
  regions      = var.pf_cr_regions
}

data "packetfabric_cloud_router" "current" {
  provider = packetfabric
  depends_on = [
    packetfabric_cloud_router.cr
  ]
}
output "cloud_router" {
  value = data.packetfabric_cloud_router.current
}
