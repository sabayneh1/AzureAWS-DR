[webservers]
%{ for ip in aws_public_ips ~}
${ip} ansible_user=ubuntu
%{ endfor ~}

%{ for ip in azure_vmss_ips ~}
${ip} ansible_user=adminuser
%{ endfor ~}
