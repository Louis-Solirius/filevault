terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
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
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "lwweaponofchoicecr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

data "azurerm_subscription" "current" {}
