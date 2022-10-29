terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.22.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.13.1"
    # }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac2weu"
    container_name       = "arc-connection"
    key                  = "terraform.tfstate"
  }

}


resource "null_resource" "non_interactive_call" {
  triggers = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/non-interactive.sh ;${path.module}/non-interactive.sh ${data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name} ${data.terraform_remote_state.aks.outputs.aks_cluster_name}"
    interpreter = ["bash", "-c"]
  }
}

data "azurerm_kubernetes_cluster" "example" {
  name                = data.terraform_remote_state.aks.outputs.aks_cluster_name
  resource_group_name = data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name
}

provider "kubernetes" {
  config_path = "./config"
  host        = data.azurerm_kubernetes_cluster.example.kube_config.0.host
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
