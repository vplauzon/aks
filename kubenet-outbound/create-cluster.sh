#!/bin/bash

##########################################################################
##  Creates a VNET with 3 subnets
##  Deploys an AKS cluster with kubenet network plugin in one subnet
##  Deploys an Azure Container Instance (ACI) in another subnet
##
##  Takes 5 parameters:
##
##  1- Name of resource group
##  2- Azure region name (must be compatible with ACI in VNET regions)
##  3- Name of cluster
##  4- Service Principal Application ID
##  5- Service Principal Object ID
##  6- Service Principal Password

rg=$1
region=$2
cluster=$3
appId=$4
appObjectId=$5
appPassword=$6

echo "Resource group:  $rg"
echo "Region:  $region"
echo "Cluster name:  $cluster"
echo "Application ID:  $appId"
echo "Application Object ID:  $appObjectId"
echo "Application Password:  $appPassword"

echo
echo "Creating group $rg in $region..."

az group create --name $rg --location $region --query "id" -o tsv

echo
echo "Fetching latest version in region $region..."

version=$(az aks get-versions --location $region --query "orchestrators[-1].orchestratorVersion" -o tsv)

echo
echo "Version:  $version"

echo
echo "Deploying cluster $cluster, VNET, NSG & ACI..."

ip=$(az group deployment create -n "deploy-$(uuidgen)" -g $rg \
    --template-file https://raw.githubusercontent.com/vplauzon/aks/master/kubenet-outbound/deploy.json \
    --parameters \
    version=$version \
    clusterName=$cluster \
    principalAppId=$appId \
    principalObjectId=$appObjectId \
    principalSecret=$appPassword \
    --query "properties.outputs.containerIp.value" \
    -o tsv)

echo
echo "Successfully deployed cluster $cluster and ACI with IP $ip"
echo

echo "Connect kubectl to newly created cluster $cluster..."
echo

 az aks get-credentials -g $rg -n $cluster