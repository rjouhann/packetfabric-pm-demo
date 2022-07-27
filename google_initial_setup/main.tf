terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.30.0"
    }
  }
}

# Make sure you enabled Compute Engine API
provider "google" {
  project     = var.gcp_project_id
  credentials = file(var.gcp_credentials)
  region      = var.gcp_region1
  zone        = var.gcp_zone1
}

# create random name to use to name objects
resource "random_pet" "name" {}

resource "google_compute_network" "vpc_1" {
  name                    = "${var.tag_name}-${random_pet.name.id}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "${var.tag_name}-${random_pet.name.id}"
  ip_cidr_range = var.subnet_cidr1
  region        = var.gcp_region1
  network       = google_compute_network.vpc_1.id
}

resource "google_compute_firewall" "ssh-rule" {
  name    = "allow-icmp-ssh-http-locust-iperf"
  network = google_compute_network.vpc_1.name
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8089", "5001"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_1" {
  name         = "${var.tag_name}-${random_pet.name.id}-vm1"
  machine_type = "e2-micro"
  zone         = var.gcp_zone1
  tags         = ["${var.tag_name}-${random_pet.name.id}"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.name
    access_config {}
  }
  metadata_startup_script = file("../user-data-ubuntu.sh")
  metadata = {
    sshKeys = "ubuntu:${var.public_key}"
  }
}

data "google_compute_instance" "vm_1" {
  name = "${var.tag_name}-${random_pet.name.id}-vm1"
  zone = var.gcp_zone1
  depends_on = [
    google_compute_instance.vm_1
  ]
}

output "private_ip_vm_1" {
  description = "Private ip address for VM for Region 1"
  value       = data.google_compute_instance.vm_1.network_interface.0.network_ip
}

output "public_ip_vm_1" {
  description = "Public ip address for VM for Region 1 (ssh user: ubuntu)"
  value       = data.google_compute_instance.vm_1.network_interface.0.access_config.0.nat_ip
}

# From the Google side: Create a Google Cloud Router with ASN 16550.
resource "google_compute_router" "router_1" {
  name    = "${var.tag_name}-${random_pet.name.id}"
  network = google_compute_network.vpc_1.id
  bgp {
    # You must select or create a Cloud Router with its Google ASN set to 16550. This is a Google requirement for all Partner Interconnects.
    asn               = 16550
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# From the Google side: Create a VLAN attachment.
resource "google_compute_interconnect_attachment" "interconnect_1" {
  name          = "${var.tag_name}-${random_pet.name.id}"
  region        = var.gcp_region1
  description   = "Interconnect to PacketFabric Network"
  type          = "PARTNER"
  admin_enabled = true # From the Google side: Accept (automatically) the connection.
  router        = google_compute_router.router_1.id
}

output "service_key1" {
  value     = google_compute_interconnect_attachment.interconnect_1.pairing_key
  sensitive = true
}
output "vlan_attachement_name" {
  value     = "${var.tag_name}-${random_pet.name.id}"
}


# From the PacketFabric side: Create a Cloud Router connection.
# => ADD PacketFabric Cloud Router and Cloud Router Connection Creation here x2 (for both Primary and Secondary GCP Connections?)

##########################################################################################
################## Comment below, uncomment after Provider status: Provisioned
##########################################################################################

# From both sides: Configure BGP.

# Expose bgpPeers from google_compute_router #11458
# https://github.com/hashicorp/terraform-provider-google/issues/11458
# Workaround: use https://github.com/terraform-google-modules/terraform-google-gcloud

# data "google_compute_router" "router_1" {
#   name    = "${var.tag_name}-${random_pet.name.id}"
#   network = google_compute_network.vpc_1.id
# }

# output "router_1" {
#   value     = data.google_compute_router.router_1
# }
