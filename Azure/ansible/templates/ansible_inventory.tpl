[azure]
%{ for ip in azure_vmss_ips ~}
azure_vm${ip} ansible_host=${ip} ansible_user=adminuser ansible_password='P@ssword1234!'
%{ endfor ~}
