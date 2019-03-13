#!/bin/bash

uniqueId=$(uuidgen)
name="deploy-$uniqueId"

az group deployment create -n $name -g aks --template-file deploy.json --parameters @deploy.parameters.json