# Set the provider
provider "azurerm" {
  features {}
}

# The image created with the packer script
data "azurerm_image" "web" {
  name                = "${var.image_name}"
  resource_group_name = var.resource_group_name
}

# Create the resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a subnet on the virtual network
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "deny-inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule{
    name                        = "allow-outbound"
    priority                    = 102
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
  }

}


#Create a network interface
resource "azurerm_network_interface" "main" {
  count               = var.number_vm
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    prefix =  "${var.prefix}"
  }
}

# Create a load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# Create the backend pool for the load balancer
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-load-balancer-backend-pool"
}

# Create address pool association for the load balancer and the network interface
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.number_vm
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Create a virtual machine availability set
resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    prefix =  "${var.prefix}"
  }
}

# Create the virtual machines
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.number_vm
  name                            = "${var.prefix}vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "${var.vm_size}"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids =  [element(azurerm_network_interface.main.*.id, count.index)]
  availability_set_id = azurerm_availability_set.main.id

  source_image_id = data.azurerm_image.web.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    prefix =  "${var.prefix}"
  }
}