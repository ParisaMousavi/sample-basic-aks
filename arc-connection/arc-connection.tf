module "rg_name_for_arc" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = "for-arc"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup_for_arc" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  count    = var.connect_to_arc == false ? 0 : 1
  location = var.location
  name     = module.rg_name_for_arc.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "null_resource" "arc-connection" {
  count = var.connect_to_arc == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/bash.sh ;${path.module}/bash.sh ${data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name} ${data.terraform_remote_state.aks.outputs.aks_cluster_name} ${var.location} ${module.resourcegroup_for_arc[0].name}"
    interpreter = ["bash", "-c"]
  }
}

# resource "null_resource" "monitoring_extension" {
#   depends_on = [
#     null_resource.arc-connection
#   ]
#   count    = var.connect_to_arc == false ? 0 : 1
#   triggers = { always_run = timestamp() }
#   // The order of input values are important for bash
#   provisioner "local-exec" {
#     command     = "az k8s-extension create --name azuremonitor-containers --cluster-name ${data.terraform_remote_state.aks.outputs.aks_cluster_name} --resource-group ${module.resourcegroup_for_arc[0].name} --cluster-type connectedClusters --extension-type Microsoft.AzureMonitor.Containers --configuration-settings logAnalyticsWorkspaceResourceID=${data.terraform_remote_state.log.outputs.log_analytics_workspace_id}"
#   }
# }
