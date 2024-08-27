#!/bin/bash

# Ensure the Azure CLI is authenticated and has access to the resource group and VMSS
RESOURCE_GROUP=$1
VMSS_NAME=$2

# Debug output
echo "Fetching IPs for VMSS: $VMSS_NAME in Resource Group: $RESOURCE_GROUP"

# Fetch the public IP addresses of all instances in the specified VMSS
az vmss list-instance-public-ips --resource-group "$RESOURCE_GROUP" --name "$VMSS_NAME" --query "[].ipAddress" -o tsv
