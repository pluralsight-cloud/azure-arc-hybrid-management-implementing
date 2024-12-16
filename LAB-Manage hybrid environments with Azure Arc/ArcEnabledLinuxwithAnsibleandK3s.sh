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

# So the agent can report completion back to ARM, allow the firewall access to ARM, then disable it and the agent after a minute
# Configure the uncomplicated firewall (UFW)
ufw --force enable
ufw default allow incoming
echo -e "sudo systemctl stop walinuxagent" | at now + 1 minute
echo -e "sudo systemctl disable walinuxagent" | at now + 1 minute
echo -e "sudo ufw deny out from any to 169.254.169.254" | at now + 1 minute