terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}

  subscription_id = "c3c359ea-23a0-4696-9b8a-2d92aafdd97c"
}

resource "azurerm_resource_group" "rg" {
  name     = "lw-weaponofchoice-rg"
  location = "uksouth"
}

resource "azurerm_container_registry" "acr" {
  name                = "lwweaponofchoicecr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "lw-weaponofchoice-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "lw-weaponofchoice-dns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}