resource "azurerm_resource_group" "craa-rg" {
  name     = "Help-rg"
  location = "East Us"
  tags = {
    environment = "dev"
  }
}
