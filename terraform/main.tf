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

resource "azurerm_service_plan" "asp" {
  name                = "file-vault-app-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_app_service" "webapp" { //NOSONAR
  name                = "louisw-fault-vault-web-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id     = azurerm_service_plan.asp.id
  https_only = true
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = azurerm_container_registry.acr.login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
    WEBSITES_PORT     = "8080"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/filevault-app-clean:latest"
  }

  auth_settings {
    enabled = true
    unauthenticated_client_action = "RedirectToLoginPage"
  }
}

data "azurerm_subscription" "current" {}
