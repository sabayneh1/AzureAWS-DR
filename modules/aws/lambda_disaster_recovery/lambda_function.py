import boto3
import subprocess

import os
import subprocess

def lambda_handler(event, context):
    client_id = os.getenv('AZURE_CLIENT_ID')
    secret = os.getenv('AZURE_CLIENT_SECRET')
    tenant = os.getenv('AZURE_TENANT_ID')
    subscription = os.getenv('AZURE_SUBSCRIPTION_ID')

    # Example of setting Azure CLI environment variables
    os.environ['AZURE_CLIENT_ID'] = client_id
    os.environ['AZURE_CLIENT_SECRET'] = secret
    os.environ['AZURE_TENANT_ID'] = tenant
    os.environ['AZURE_SUBSCRIPTION_ID'] = subscription

    # Trigger the Azure deployment using Azure CLI
    subprocess.call(["az", "group", "deployment", "create", "--template-file", "azuredeploy.json", "--parameters", "@azuredeploy.parameters.json"])

    return {
        'statusCode': 200,
        'body': 'Triggered disaster recovery deployment in Azure'
    }
