resource "azurerm_virtual_network" "vnet" {
  name                = "ansible-app-server-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "ansible-app-server-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "ansible-app-server-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh-allow"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.trusted_ip
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "ssh-allow2"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.trusted_ip2
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "8080-allow"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "8080"
  }

  security_rule {
    name                       = "prometheus-allow"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "9090"
  }

  security_rule {
    name                       = "grafana-allow"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "3001"
  }
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "ansible-app-server-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "ansible-app-server-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_backend_pool" {
  name                = "vmss-backend-pool"
  loadbalancer_id     = azurerm_lb.vmss_lb.id
}

resource "azurerm_lb_nat_pool" "vmss_nat_pool" {
  name                           = "ssh-nat-pool"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50010
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_rule" "app_lb_rule" {
  name                           = "app-lb-rule"
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids        = [
    azurerm_lb_backend_address_pool.vmss_backend_pool.id,
  ]
}

resource "azurerm_lb_rule" "prometheus_lb_rule" {
  name                           = "prometheus_lb_rule"
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 9090
  backend_port                   = 9090
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids        = [
    azurerm_lb_backend_address_pool.vmss_backend_pool.id,
  ]
}

resource "azurerm_lb_rule" "grafana_lb_rule" {
  name                           = "grafana_lb_rule"
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 3001
  backend_port                   = 3001
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids        = [
    azurerm_lb_backend_address_pool.vmss_backend_pool.id,
  ]
}
