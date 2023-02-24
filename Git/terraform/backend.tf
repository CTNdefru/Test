terraform {
  backend "azurerm" {
    resource_group_name  = "TF-AzDo-Demo-RG"
    storage_account_name = "tfazdodemostg0102"
    container_name       = "terraform-state"
    key                  = "tf-azdo-demo0151.tfstate"

  }
}