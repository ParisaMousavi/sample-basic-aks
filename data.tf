data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "enterprise-network"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "enterprise-monitoring"
    key                  = "terraform.tfstate"
  }
}

data "azuread_service_principal" "deployment_sp" {
  display_name = "technical-user-for-devops"
}

data "azuread_group" "aks_cluster_admin" {
  display_name     = "AKS Cluster Admin"
  security_enabled = true
}

data "azuread_group" "aks_cluster_developer" {
  display_name     = "AKS Cluster Developer"
  security_enabled = true
}