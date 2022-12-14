data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "sample-basic-aks"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "log" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "enterprise-monitoring"
    key                  = "terraform.tfstate"
  }
}