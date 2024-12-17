# Install the Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Ansible
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible

# Install sshpass (for Ansible connections using SSH passwords)
sudo apt-get update
sudo apt-get install sshpass

# Install and enable the at command
sudo apt-get update 
sudo apt-get install at
sudo systemctl enable atd
sudo systemctl start atd

# Configure for Arc-onboarding
ufw --force enable
ufw default allow incoming
echo -e "sudo systemctl stop walinuxagent" | at now + 1 minute
echo -e "sudo systemctl disable walinuxagent" | at now + 1 minute
echo -e "sudo ufw deny out from any to 169.254.169.254" | at now + 1 minute