import os
import subprocess
import boto3
from botocore.exceptions import ClientError
import json
import requests

def get_secret():
    secret_name = "my_azure_credentials"
    region_name = "ca-central-1"

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

def get_elb_dns_name():
    client = boto3.client('elbv2')
    elbs = client.describe_load_balancers()
    elb_dns_name = elbs['LoadBalancers'][0]['DNSName']  # Assuming you have one ELB
    return elb_dns_name

def check_elb_health(elb_dns_name):
    try:
        response = requests.get(f"http://{elb_dns_name}", timeout=10)
        status_code = response.status_code
        print(f"ELB health check status code: {status_code}")
        if status_code == 200:
            return True
        else:
            return False
    except requests.exceptions.RequestException as e:
        print(f"ELB health check failed: {e}")
        return False

def get_azure_vm_ips():
    result = subprocess.run(
        ["az", "vm", "list-ip-addresses", "--resource-group", "forStringConnection", "--query", "[].virtualMachine.network.publicIpAddresses[0].ipAddress", "-o", "tsv"],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"Failed to retrieve Azure VM IPs: {result.stderr}")
        return []

    azure_ips = result.stdout.strip().split("\n")
    print(f"Retrieved Azure VM IPs: {azure_ips}")
    return azure_ips

def run_ansible(azure_ips):
    inventory_content = "[azure]\n"
    inventory_content += "\n".join([f"{ip} ansible_user=adminuser ansible_password='P@ssword1234!'" for ip in azure_ips])

    with open("/tmp/azure_inventory", "w") as inventory_file:
        inventory_file.write(inventory_content)

    # Set the environment variable for Ansible
    ansible_env = os.environ.copy()
    ansible_env['ANSIBLE_HOST_KEY_CHECKING'] = 'False'

    ansible_command = [
        "ansible-playbook",
        "-i", "/tmp/azure_inventory",
        "/home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ansible/site.yml"
    ]
    subprocess.run(ansible_command, env=ansible_env)


def lambda_handler(event, context):
    credentials = get_secret()
    client_id = credentials['AZURE_CLIENT_ID']
    secret = credentials['AZURE_CLIENT_SECRET']
    tenant = credentials['AZURE_TENANT_ID']
    subscription = credentials['AZURE_SUBSCRIPTION_ID']

    os.environ['AZURE_CLIENT_ID'] = client_id
    os.environ['AZURE_CLIENT_SECRET'] = secret
    os.environ['AZURE_TENANT_ID'] = tenant
    os.environ['AZURE_SUBSCRIPTION_ID'] = subscription

    elb_dns_name = get_elb_dns_name()

    if not check_elb_health(elb_dns_name):
        print("ELB health check failed or web server not responding correctly. Initiating disaster recovery.")

        # Clone the GitHub repository
        subprocess.run(["git", "clone", "https://github.com/sabayneh1/AzureAWS-DR.git", "/tmp/AzureAWS-DR"])

        # Change directory to the Terraform folder for Azure
        os.chdir("/tmp/AzureAWS-DR/azure")

        # Apply the Terraform configuration for Azure
        subprocess.run([
            "terraform", "apply",
            "-target=module.azure_vnet",
            "-target=module.azure_compute_vmss",
            "-target=module.azure_lb",
            "-target=module.azure_scaling",
            "-auto-approve"
        ])

        # After deploying, get Azure VM IPs
        azure_ips = get_azure_vm_ips()

        # Run Ansible for Azure VMs
        run_ansible(azure_ips)

        if not check_elb_health("your-azure-lb-dns-name"):
            print("Azure LB health check failed after deployment.")
        else:
            print("Azure LB is healthy after deployment.")
    else:
        print("ELB is healthy, no action needed.")

    return {
        'statusCode': 200,
        'body': 'Checked ELB and triggered disaster recovery deployment if necessary'
    }
