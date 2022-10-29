resourcegroupname=$1
aksclustername=$2
location=$3
resourcegroupnameforarc=$4

export KUBECONFIG=./config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Registering Azure Arc providers
echo "Registering Azure Arc providers"
az provider register --namespace Microsoft.Kubernetes --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
az provider register --namespace Microsoft.ExtendedLocation --wait

az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

# Getting AKS credentials
echo "Getting AKS credentials (kubeconfig)"
echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername" --file ./config
az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ./config
kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

# Installing Azure Arc k8s CLI extensions
echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""


echo "Clear cached helm Azure Arc Helm Charts"
rm -rf ~/.azure/AzureArcCharts

# Installing Azure Arc k8s CLI extensions
echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""

echo "Connecting the cluster to Azure Arc"

az connectedk8s connect --name "$aksclustername" --resource-group "$resourcegroupnameforarc" --location "$location" --custom-locations-oid "22cfa2da-1491-4abc-adb3-c31c8c74cefa"

az connectedk8s enable-features --name "$aksclustername" --resource-group "$resourcegroupnameforarc" --features cluster-connect custom-locations --custom-locations-oid "22cfa2da-1491-4abc-adb3-c31c8c74cefa"

echo "--------------------------------------\n"
echo "List of useful commands \n"
echo "--------------------------------------\n"

echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername --file ./config"

echo "az k8s-extension list --resource-group $resourcegroupnameforarc --cluster-name $aksclustername --cluster-type connectedClusters"

echo "az k8s-extension show --name azuremonitor-containers --resource-group $resourcegroupnameforarc --cluster-name $aksclustername --cluster-type connectedClusters"

echo "az k8s-extension create --name azuremonitor-containers  --extension-type Microsoft.AzureMonitor.Containers --scope cluster --resource-group $resourcegroupnameforarc --cluster-name $aksclustername --cluster-type connectedClusters"



# kubectl create serviceaccount arc-user

# kubectl create clusterrolebinding arc-user-binding --clusterrole cluster-admin --serviceaccount default:arc-user

# kubectl apply -f - <<EOF
# apiVersion: v1
# kind: Secret
# metadata:
#   name: arc-user-secret
#   annotations:
#     kubernetes.io/service-account.name: arc-user
# type: kubernetes.io/service-account-token
# EOF 

# TOKEN=$(kubectl get secret arc-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g') 

# echo $TOKEN
