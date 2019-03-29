#!/bin/bash

##########################################################################
##  Creates a VNET with 2 subnets
##  NSG lets port 80 get into the services subnet
##  Deploys an AKS cluster with kubenet network plugin in AKS subnet
##
##  Takes 5 parameters:
##
##  1- Name of resource group
##  2- Azure region name (must be compatible with ACI in VNET regions)
##  3- Name of cluster
##  4- Service Principal Application ID
##  5- Service Principal Object ID
##  6- Service Principal Password

#   Make sure the script fails if any subcommand fail
set -e

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
echo "Deploying cluster $cluster, VNET & NSG..."

nrg=$(az group deployment create -n "deploy-$(uuidgen)" -g $rg \
    --template-file deploy.json \
    --parameters \
    version=$version \
    clusterName=$cluster \
    principalAppId=$appId \
    principalObjectId=$appObjectId \
    principalSecret=$appPassword \
    --query "properties.outputs.nodeResourceGroup.value" \
    -o tsv)

echo
echo "Successfully deployed cluster $cluster"

echo
echo "Looking for Route table in $nrg..."

routeTableId=$(az network route-table list -g $nrg --query "[0].id" -o tsv)

echo
echo "Looking for Virtual Network in $rg..."

vnet=$(az network vnet list -g $rg --query "[0].name" -o tsv)

echo
echo "Connection route table $routeTableId in Virtual Network $vnet..."

#   Run two commands (for 2 subnets) in parallel, i.e. fork and join
az network vnet subnet update -g $rg -n aks --vnet-name $vnet --route-table $routeTableId
az network vnet subnet update -g $rg -n services --vnet-name $vnet --route-table $routeTableId

echo
echo "Connect kubectl to newly created cluster $cluster..."
echo

az aks get-credentials -g $rg -n $cluster