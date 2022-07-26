terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = "0.1.0"
    }
  }
}

provider "packetfabric" {
  host  = var.pf_api_server
  token = var.pf_api_key
}

data "aws_cloud_router_connection" "current" {
  provider   = packetfabric
  circuit_id = var.cloud_router_circuit_id
}
locals {
  aws_cloud_connections = data.aws_cloud_router_connection.current.aws_cloud_connections[*]
  helper_map = { for val in local.aws_cloud_connections :
  val["description"] => val }
  cc1 = local.helper_map["${var.crc_name}"]
}
output "cc1_vlan_id_pf" {
  value = one(local.cc1.cloud_settings[*].vlan_id_pf)
}
output "cc1_public_ip" { # Public AWS Router Peer IP
  value = "${cidrhost(one(local.cc1.cloud_settings[*].public_ip), 0)}/${element(split("/", "${one(local.cc1.cloud_settings[*].public_ip)}"), 1)}"
}
output "cc1_customer_address" { # PacketFabric Router Peer IP
  value = "${cidrhost(one(local.cc1.cloud_settings[*].public_ip), 1)}/${element(split("/", "${one(local.cc1.cloud_settings[*].public_ip)}"), 1)}"
}
output "aws_cloud_router_connection" {
  value = data.aws_cloud_router_connection.current.aws_cloud_connections[*]
}