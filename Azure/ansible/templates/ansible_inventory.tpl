[aws]
%{ for ip in aws_public_ips ~}
aws_vm${ip} ansible_host=${ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ubuntu.pem
%{ endfor ~}

[azure]
%{ for ip in azure_vmss_ips ~}
azure_vm${ip} ansible_host=${ip} ansible_user=adminuser ansible_password='P@ssword1234!'
%{ endfor ~}
