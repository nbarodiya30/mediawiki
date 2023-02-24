# Define the resource group
resource "azurerm_resource_group" "mediawiki" {
  name     = "mediawiki-resource-group"
  location = "East US"
}

# Define the virtual network
resource "azurerm_virtual_network" "mediawiki" {
  name                = "mediawiki-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mediawiki.location
  resource_group_name = azurerm_resource_group.mediawiki.name
}

# Define the subnet
resource "azurerm_subnet" "mediawiki" {
  name                 = "mediawiki-subnet"
  resource_group_name  = azurerm_resource_group.mediawiki.name
  virtual_network_name = azurerm_virtual_network.mediawiki.name
  address_prefix       = "10.0.1.0/24"
}

# Define the public IP address
resource "azurerm_public_ip" "mediawiki" {
  name                = "mediawiki-ip"
  location            = azurerm_resource_group.mediawiki.location
  resource_group_name = azurerm_resource_group.mediawiki.name
  allocation_method   = "Dynamic"
}

# Define the network interface
resource "azurerm_network_interface" "mediawiki" {
  name                = "mediawiki-nic"
  location            = azurerm_resource_group.mediawiki.location
  resource_group_name = azurerm_resource_group.mediawiki.name

  ip_configuration {
    name                          = "mediawiki-ipconfig"
    subnet_id                     = azurerm_subnet.mediawiki.id
    public_ip_address_id          = azurerm_public_ip.mediawiki.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the virtual machine
resource "azurerm_virtual_machine" "mediawiki" {
  name                  = "mediawiki-vm"
  location              = azurerm_resource_group.mediawiki.location
  resource_group_name   = azurerm_resource_group.mediawiki.name
  network_interface_ids = [azurerm_network_interface.mediawiki.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "mediawiki-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "mediawiki-vm"
    admin_username = "mediawikiadmin"
    admin_password = "P@ssw0rd1234"
