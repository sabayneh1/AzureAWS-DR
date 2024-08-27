#!/bin/bash

RESOURCE_GROUP=$1
VMSS_NAME_PREFIX=$2

echo "Resource Group: $RESOURCE_GROUP"
echo "VMSS Name Prefix: $VMSS_NAME_PREFIX"

VMSS_NAME=$(az vmss list --resource-group "$RESOURCE_GROUP" --query "[?starts_with(name, '$VMSS_NAME_PREFIX')].name | [0]" -o tsv)

echo "Full VMSS Name: $VMSS_NAME"

if [ -z "$VMSS_NAME" ]; then
  echo "Error: Could not find a VMSS with the prefix $VMSS_NAME_PREFIX"
  exit 1
fi

echo "Fetching IPs for VMSS: $VMSS_NAME in Resource Group: $RESOURCE_GROUP"

az vmss list-instance-public-ips --resource-group "$RESOURCE_GROUP" --name "$VMSS_NAME" --query "[].ipAddress" -o tsv
