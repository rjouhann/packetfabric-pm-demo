terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.88.1"
    }
  }
}

provider "oci" {
  region               = var.oracle_region1
  auth                 = "APIKey"
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  private_key          = var.private_key
  #private_key_password = var.private_key_password
  fingerprint          = var.fingerprint
}

# create random name to use to name objects
resource "random_pet" "name" {}

resource "oci_identity_compartment" "new_compartment" {
  compartment_id = var.compartment_id
  description = "${var.tag_name}-${random_pet.name.id}"
  name        = "${var.tag_name}-${random_pet.name.id}"
}

resource "oci_core_vcn" "subnet_cidr1" {
  compartment_id = oci_identity_compartment.new_compartment.id
  display_name   = "${var.tag_name}-${random_pet.name.id}"
  cidr_block     = var.subnet_cidr1
}

