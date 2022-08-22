terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.88.1"
    }
  }
}

provider "oci" {
  region       = var.oracle_region1
  auth         = "APIKey"
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  private_key  = var.private_key
  #private_key_password = var.private_key_password
  fingerprint = var.fingerprint
}

# create random name to use to name objects
resource "random_pet" "name" {}

# create a compartment
resource "oci_identity_compartment" "compartment_1" {
  compartment_id = var.parent_compartment_id
  name           = "${var.tag_name}-${random_pet.name.id}"
  description    = "Compartment demo 1"
  enable_delete  = true
}

# create a Virtual Network
resource "oci_core_vcn" "subnet_1" {
  compartment_id = oci_identity_compartment.compartment_1.id
  display_name   = "${var.tag_name}-${random_pet.name.id}"
  cidr_block     = var.subnet_cidr1
}

output "oci_core_vcn" {
  value = oci_core_vcn.subnet_1
}

# Create a dynamic routing gateway
resource "oci_core_drg" "dyn_routing_gw_1" {
    compartment_id = oci_identity_compartment.compartment_1.id
    display_name = "${var.tag_name}-${random_pet.name.id}"
}

output "oci_core_drg" {
  value = oci_core_drg.dyn_routing_gw_1
}

data "oci_core_fast_connect_provider_services" "packetfabric_provider" {
    compartment_id = oci_identity_compartment.compartment_1.id
    filter {
      name   = "provider_name"
      values = ["PacketFabric"]
    }
  }

output "oci_core_fast_connect_provider_services" {
  value = data.oci_core_fast_connect_provider_services.packetfabric_provider
}

# Create a FastConnect connection 
resource "oci_core_virtual_circuit" "fast_connect_1" {
    compartment_id = oci_identity_compartment.compartment_1.id
    display_name = "${var.tag_name}-${random_pet.name.id}"
    region = var.oracle_region1
    type = "PRIVATE"
    gateway_id = oci_core_drg.dyn_routing_gw_1.id
    bandwidth_shape_name = var.bandwidth_shape_name
    customer_asn = var.peer_asn
    ip_mtu = "MTU_1500" # or "MTU_9000"
    is_bfd_enabled = false
    cross_connect_mappings {
        bgp_md5auth_key = var.shared_key
        customer_bgp_peering_ip = var.primary_peer_address_prefix
        oracle_bgp_peering_ip = var.secondary_peer_address_prefix
    }
    provider_service_id = data.oci_core_fast_connect_provider_services.packetfabric_provider.fast_connect_provider_services.0.id
    # public_prefixes {
    #     cidr_block = var.virtual_circuit_public_prefixes_cidr_block
    # }
    # routing_policy = var.virtual_circuit_routing_policy
}

data "oci_core_virtual_circuit" "fast_connect_1" {
    virtual_circuit_id = oci_core_virtual_circuit.fast_connect_1.id
}

output "oci_core_virtual_circuit_ocid" {
  value = oci_core_virtual_circuit.fast_connect_1.id
  sensitive = true
}