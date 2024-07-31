# resource "azurerm_resource_group" "rg" {
#   name     = "Docker-Swarm-Resources"
#   location = "eastus2"
# }

# resource "azurerm_virtual_network" "vnet" {
#   for_each = {
#     for instance in var.instance_set:
#     instance.name => instance
#   }

#   name                = each.value.vnet
#   address_space       = each.value.cidr
#   location            = each.value.region
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_subnet" "subnet" {
#   for_each = {
#     for index, instance in var.instance_set:
#     instance.name => instance
#   }
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet[each.key].name
#   address_prefixes     = each.value.subnet
# }

# resource "azurerm_public_ip" "public_ip" {
#   for_each = {
#     for index, instance in var.instance_set:
#     instance.name => instance
#   }

#   name                = "${each.value.name}-pip"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = each.value.region
#   allocation_method   = "Dynamic"
# }

# resource "azurerm_network_interface" "nic" {
#   for_each = {
#     for index, instance in var.instance_set:
#     instance.name => instance
#   }
#   name                = "${each.value.name}-nic"
#   location            = each.value.region
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.subnet[each.key].id
#     public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
#   }
# }

# # resource "azurerm_virtual_network_peering" "example-1" {
# #   for_each = {
# #     for index, instance in var.instance_set:
# #     instance.name => instance
# #   }

# #   name                      = "peer"
# #   resource_group_name       = azurerm_resource_group.rg.name
# #   virtual_network_name      = each.value.vnet
# #   remote_virtual_network_id = azurerm_virtual_network.vnet[each.key].id
# # }


# # Create Network Security Group and rule
# resource "azurerm_network_security_group" "nsg" {
#   for_each = {
#     for index, instance in var.instance_set:
#     instance.name => instance
#   }

#   name                = each.value.nsg
#   location            = each.value.region
#   resource_group_name = azurerm_resource_group.rg.name
# # Note that this rule will allow all external connections from internet to SSH port
  
#   security_rule {
#     name                       = "SSH"
#     priority                   = 200
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }



# resource "tls_private_key" "secureadmin_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "azurerm_linux_virtual_machine" "vm" {
#   for_each = {
#     for index, instance in var.instance_set:
#     instance.name => instance
#   }

#   name                = each.value.name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = each.value.region
#   size                = "Standard_F1s"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.nic[each.key].id,
#   ]

#   disable_password_authentication = true

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = tls_private_key.secureadmin_ssh.public_key_openssh
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   custom_data = filebase64("custom_data/docker.sh")

#   depends_on =  [ azurerm_network_interface.nic ]
# }


resource "azurerm_resource_group" "rg" {
  name     = "Docker-Swarm-Resources"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  for_each = {for vnet in var.vnets: vnet.name => vnet}

  name                = each.value.name
  address_space       = each.value.cidr
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  for_each = {for vnet in var.vnets: vnet.name => vnet}
  
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.subnet
}

resource "azurerm_public_ip" "public_ip" {
  for_each = {for instance in var.instance_set: instance.name => instance}

  name                = "${each.value.name}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = each.value.region
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  for_each = {for instance in var.instance_set: instance.name => instance}

  name                = "${each.value.name}-nic"
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet[each.value.vnet].id
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = {for vnet in var.vnets: vnet.name => vnet}

  name                = each.value.nsg
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg.name
# Note that this rule will allow all external connections from internet to SSH port
  
  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  for_each = {for vnet in var.vnets: vnet.name => vnet}

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = {for instance in var.instance_set: instance.name => instance}

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = each.value.region
  size                = "Standard_F1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("custom_data/docker.sh")

  depends_on =  [ azurerm_network_interface.nic ]
}