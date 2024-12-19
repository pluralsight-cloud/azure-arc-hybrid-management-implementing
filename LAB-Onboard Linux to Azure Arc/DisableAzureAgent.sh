# Install and enable the at command
apt-get update 
apt-get install at
systemctl enable atd
systemctl start atd

# Disable the Azure VM Guest Agent
echo "sudo systemctl stop walinuxagent" | at now + 2 minute
echo "sudo systemctl disable walinuxagent" | at now + 2 minute

# Configure its uncomplicated firewall (UFW)
echo -e "sudo ufw allow ssh\nsudo ufw deny out from any to 169.254.169.254\nsudo ufw enable\nsudo ufw status > /tmp/ufw.txt" | at now + 2 minute 