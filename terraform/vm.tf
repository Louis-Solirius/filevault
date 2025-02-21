resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "example-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vm_size
  instances           = 1
  admin_username      = var.vm_admin_username

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_ed25519_2.pub")
  }

  disable_password_authentication = true

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = azurerm_subnet.subnet.id
      primary   = true
    }

    network_security_group_id = azurerm_network_security_group.vm_nsg.id
  }
}
