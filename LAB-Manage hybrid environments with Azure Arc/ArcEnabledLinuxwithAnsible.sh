# Install the Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Ansible
apt-get update
apt-get install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Install sshpass (for Ansible connections using SSH passwords)
apt-get update
apt-get install -y sshpass

# Install and enable the at command
apt-get update 
apt-get install -y at
systemctl enable atd
systemctl start atd

# Configure for Arc-onboarding
ufw --force enable
ufw default allow incoming
echo -e "sudo systemctl stop walinuxagent && sudo systemctl disable walinuxagent && sudo ufw deny out from any to 169.254.169.254" | at now + 3 minute

# List scheduled at jobs
atq