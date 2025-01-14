# Install the Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install K3s
curl -sfL https://get.k3s.io | sh -

# Install Ansible
apt-get update
apt-get install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Install sshpass (for Ansible connections using SSH passwords)
apt-get update
apt-get install -y sshpass