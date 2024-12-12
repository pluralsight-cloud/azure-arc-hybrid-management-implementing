# Install the Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install K3s
curl -sfL https://get.k3s.io | sh -

# Install Ansible
apt-get update
apt-get install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install ansible

# Install sshpass (for Ansible connections using SSH passwords)
apt-get update
apt-get install sshpass

# Install and enable the at command
apt-get update 
apt-get install at
systemctl enable atd
systemctl start atd

# Disable the Azure VM Guest Agent
echo "sudo systemctl stop walinuxagent" | at now + 1 minute
echo "sudo systemctl disable walinuxagent" | at now + 1 minute

# Configure its uncomplicated firewall (UFW)
echo -e "sudo ufw allow ssh\nsudo ufw deny out from any to 169.254.169.254\nsudo ufw enable\nsudo ufw status > /tmp/ufw.txt" | at now + 1 minute 