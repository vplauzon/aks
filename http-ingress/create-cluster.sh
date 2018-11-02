az group create --name aks-group --location eastus2
az aks create --resource-group aks-group --name aks-cluster --node-count 3 --generate-ssh-keys -s Standard_B2ms
az aks get-credentials -g aks-group -n aks-cluster
