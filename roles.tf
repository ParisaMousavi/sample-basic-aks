resource "azurerm_role_assignment" "aks_cluster_admin_role" {
  principal_id         = data.azuread_group.aks_cluster_admin.id
  scope                = module.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  depends_on = [
    module.aks
  ]
}

resource "azurerm_role_assignment" "aks_cluster_developer_role" {
  principal_id         = data.azuread_group.aks_cluster_developer.id
  scope                = module.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  depends_on = [
    module.aks
  ]
}