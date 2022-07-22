terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Disable Azure Network watcher auto creation (lab only)
# az feature register --name DisableNetworkWatcherAutocreation --namespace Microsoft.Network
# az provider register -n Microsoft.Network

# # create Azure Network watcher before Azure creates one
# resource "azurerm_resource_group" "resource_group_network_watcher_1" {
#   name     = "${var.tag_name}-${random_pet.name.id}-NetworkWatcherRG"
#   location = var.azure_region1
# }
# resource "azurerm_network_watcher" "main" {
#   name                = "${var.tag_name}-${random_pet.name.id}"
#   location            = azurerm_resource_group.resource_group_1.location
#   resource_group_name = azurerm_resource_group.resource_group_network_watcher_1.name
# }

# create random name to use to name objects
resource "random_pet" "name" {}

resource "azurerm_resource_group" "resource_group_1" {
  name     = "${var.tag_name}-${random_pet.name.id}"
  location = var.azure_region1
}

resource "azurerm_virtual_network" "virtual_network_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-vnet1"
  location            = azurerm_resource_group.resource_group_1.location
  resource_group_name = azurerm_resource_group.resource_group_1.name
  address_space       = ["${var.vnet_cidr1}"]
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "${var.tag_name}-${random_pet.name.id}-subnet1"
  address_prefixes     = ["${var.subnet_cidr1}"]
  resource_group_name  = azurerm_resource_group.resource_group_1.name
  virtual_network_name = azurerm_virtual_network.virtual_network_1.name
}

# Subnet used for the azurerm_virtual_network_gateway only
resource "azurerm_subnet" "subnet_gw" {
  name                 = "GatewaySubnet"
  address_prefixes     = ["${var.subnet_cidr1gw}"]
  resource_group_name  = azurerm_resource_group.resource_group_1.name
  virtual_network_name = azurerm_virtual_network.virtual_network_1.name
}

resource "azurerm_network_security_group" "security_group_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-sec-group1"
  location            = azurerm_resource_group.resource_group_1.location
  resource_group_name = azurerm_resource_group.resource_group_1.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ICMP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Nginx"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Locust"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8089"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "IPERF"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
}

resource "azurerm_public_ip" "public_ip_vm_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-public-ip-vm1"
  resource_group_name = azurerm_resource_group.resource_group_1.name
  location            = azurerm_resource_group.resource_group_1.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
}

resource "azurerm_network_interface" "nic_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-nic1"
  location            = azurerm_resource_group.resource_group_1.location
  resource_group_name = azurerm_resource_group.resource_group_1.name

  ip_configuration {
    name                          = "${var.tag_name}-${random_pet.name.id}"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_vm_1.id
  }
  depends_on = [
    azurerm_public_ip.public_ip_vm_1,
    azurerm_subnet.subnet_1
  ]
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
}

resource "azurerm_network_interface_security_group_association" "association_1" {
  network_interface_id      = azurerm_network_interface.nic_1.id
  network_security_group_id = azurerm_network_security_group.security_group_1.id
}

resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = "${var.tag_name}-${random_pet.name.id}-sshkey"
  location            = azurerm_resource_group.resource_group_1.location
  resource_group_name = azurerm_resource_group.resource_group_1.name
  public_key          = var.public_key
}

## TO ADD: installation of demo nginx server and locust, reuse the same script from the aws demo setup
resource "azurerm_virtual_machine" "vm_1" {
  name                             = "${var.tag_name}-${random_pet.name.id}-vm1"
  location                         = azurerm_resource_group.resource_group_1.location
  resource_group_name              = azurerm_resource_group.resource_group_1.name
  network_interface_ids            = [azurerm_network_interface.nic_1.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.tag_name}-${random_pet.name.id}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "${var.tag_name}-${random_pet.name.id}-azure"
    admin_username = "ubuntu"
    custom_data = file("../user-data-ubuntu.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = azurerm_ssh_public_key.ssh_public_key.public_key
      path     = "/home/ubuntu/.ssh/authorized_keys"
    }
  }
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
  depends_on = [
    azurerm_network_interface.nic_1
  ]
}

data "azurerm_network_interface" "nic_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-nic1"
  resource_group_name = azurerm_resource_group.resource_group_1.name
  depends_on = [
    azurerm_virtual_machine.vm_1
  ]
}

output "private_ip_vm_1" {
  description = "Private ip address for VM for Region 1"
  value       = data.azurerm_network_interface.nic_1.private_ip_address
}

data "azurerm_public_ip" "public_ip_vm_1" {
  name                = "${var.tag_name}-${random_pet.name.id}-public-ip-vm1"
  resource_group_name = azurerm_resource_group.resource_group_1.name
  depends_on = [
    azurerm_virtual_machine.vm_1
  ]
}

output "public_ip_vm_1" {
  description = "Public ip address for VM for Region 1"
  value       = data.azurerm_public_ip.public_ip_vm_1.ip_address
}

output "admin_username" {
  value     = var.admin_username
  sensitive = true
}
output "admin_password" {
  value     = var.admin_password
  sensitive = true
}

# From the Microsoft side: Create an ExpressRoute circuit in the Azure Console.
resource "azurerm_express_route_circuit" "azure_express_route_1" {
  name                  = "${var.tag_name}-${random_pet.name.id}"
  resource_group_name   = azurerm_resource_group.resource_group_1.name
  location              = azurerm_resource_group.resource_group_1.location
  peering_location      = var.peering_location_1
  service_provider_name = var.service_provider_name
  bandwidth_in_mbps     = var.bandwidth_in_mbps
  sku {
    tier   = var.sku_tier
    family = var.sku_family
  }
  tags = {
    environment = "${var.tag_name}-${random_pet.name.id}"
  }
  ## Add a dependency on PF CRC
}
# Pre-req to enable AzureExpressRoute in the Azure Subscription
# az feature register --namespace Microsoft.Network --name AllowExpressRoutePorts
# az provider register -n Microsoft.Network

output "service_key1" {
  value     = azurerm_express_route_circuit.azure_express_route_1.service_key
  sensitive = true
}

# From the PacketFabric side: Create a Cloud Router connection.
# => ADD PacketFabric Cloud Router and Cloud Router Connection Creation here x2 (for both Primary and Secondary Azure Connections)

##########################################################################################
################## Comment below, uncomment after Provider status: Provisioned
##########################################################################################

# # From both sides: Configure BGP.
# resource "azurerm_express_route_circuit_peering" "private_circuit_1" {
#   peering_type                  = "AzurePrivatePeering"
#   express_route_circuit_name    = azurerm_express_route_circuit.azure_express_route_1.name
#   resource_group_name           = azurerm_resource_group.resource_group_1.name
#   peer_asn                      = 4556 # PacketFabric ASN
#   primary_peer_address_prefix   = "169.254.247.40/30"
#   secondary_peer_address_prefix = "169.254.248.40/30"
#   vlan_id                       = 11
#   shared_key                    = "dd02c7c2232759874e1c20558" # echo "secret" | md5sum | cut -c1-25
#   depends_on = [
#     azurerm_express_route_circuit.azure_express_route_1
#   ]
# }

# => ADD PacketFabric Cloud Router BGP Setting Creation here x2 (for both Primary and Secondary Azure Connections)
#    including Prefixes on all CRC part of this Cloud Router, e.g. AWS)

##########################################################################################
################## Comment below, uncomment after BGP sessions are setup
##########################################################################################

# # From the Microsoft side: Create a virtual network gateway for ExpressRoute.
# resource "azurerm_public_ip" "public_ip_vng_1" {
#   name                = "${var.tag_name}-${random_pet.name.id}-public-ip-vng1"
#   location            = azurerm_resource_group.resource_group_1.location
#   resource_group_name = azurerm_resource_group.resource_group_1.name
#   allocation_method   = "Dynamic"
#   tags = {
#     environment = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# # This resource creation can take up to 50min - deletion up to 12min
# resource "azurerm_virtual_network_gateway" "vng_1" {
#   name                = "${var.tag_name}-${random_pet.name.id}-vng1"
#   location            = azurerm_resource_group.resource_group_1.location
#   resource_group_name = azurerm_resource_group.resource_group_1.name
#   type                = "ExpressRoute"
#   sku                 = "Standard"
#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.public_ip_vng_1.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.subnet_gw.id
#   }
#   depends_on = [
#     azurerm_public_ip.public_ip_vng_1,
#     azurerm_subnet.subnet_gw
#   ]
#   tags = {
#     environment = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # From the Microsoft side: Link a virtual network gateway to the ExpressRoute circuit.
# resource "azurerm_virtual_network_gateway_connection" "vng_connection_1" {
#   name                       = "${var.tag_name}-${random_pet.name.id}-vng_connection_1"
#   location                   = azurerm_resource_group.resource_group_1.location
#   resource_group_name        = azurerm_resource_group.resource_group_1.name
#   type                       = "ExpressRoute"
#   express_route_circuit_id   = azurerm_express_route_circuit.azure_express_route_1.id
#   virtual_network_gateway_id = azurerm_virtual_network_gateway.vng_1.id
#   routing_weight             = 0
#   depends_on = [
#     azurerm_express_route_circuit.azure_express_route_1,
#     azurerm_virtual_network_gateway.vng_1
#   ]
#   tags = {
#     environment = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
