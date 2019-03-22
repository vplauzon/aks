#!/bin/bash

##########################################################################
##  Create an AKS cluster with kubenet network plugin
##  Also create a VNET with 2 subnets

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

nrg=$(az group deployment create -n "deploy-$(uuidgen)" -g $rg --template-file deploy.json \
    --parameters \
    version=$version \
    clusterName=$cluster \
    principalAppId=$appId \
    principalObjectId=$appObjectId \
    principalSecret=$appPassword \
    --query "properties.outputs.nodeResourceGroup.value" \
    -o tsv)

echo
echo "Successfully deployed cluster $cluster with node resource group in $nsg"
echo

echo "Connect kubectl to newly created cluster $cluster..."
echo

 az aks get-credentials -g $rg -n $cluster