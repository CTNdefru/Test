terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.44.0"
    }
  }
}

#provider "azuread" {}
provider "azurerm" {
  features {}
  subscription_id = var.spn-subscription-id
  client_id       = var.spn-client-id
  client_secret   = var.spn-client-secret
  tenant_id       = var.spn-tenant-id
}