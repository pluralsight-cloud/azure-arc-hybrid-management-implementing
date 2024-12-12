# Install and enable the at command
apt-get update 
apt-get install at
systemctl enable atd
systemctl start atd

# Install the Azure CLI
apt update
apt install azure-cli -y

# Authenticate with Azure
az login --identity

# Set Variables
RG=$(az group list --query [].name --output tsv)
LOCATION=$(az group list --query [].location --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RESOURCE_NAME="Arc-"$(hostname)

# Get an access token
TOKEN=$(az account get-access-token --resource-type arm --query accessToken --output tsv)

# Download the installation package.
wget https://aka.ms/azcmagent -O ~/Install_linux_azcmagent.sh

# Configure its uncomplicated firewall (UFW)
ufw --force enable
ufw deny out from any to 169.254.169.254
ufw default allow incoming

# Install the Azure Connected Machine agent.
bash ~/Install_linux_azcmagent.sh

# Configure it to communicate with the Azure Arc service 
azcmagent connect --resource-group $RG --tenant-id $TENANT_ID --location $LOCATION --subscription-id $SUBSCRIPTION_ID --resource-name $RESOURCE_NAME --access-token $TOKEN
if [ $? = 0 ]; then echo "\033[33mTo view your onboarded server(s), navigate to https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.HybridCompute%2Fmachines\033[m"; fi

# So the agent can report completion back to ARM, allow the firewall access to ARM, then disable it and the agent after a minute
ufw allow out from any to 169.254.169.254
echo -e "sudo systemctl stop walinuxagent" | at now + 1 minute
echo -e "sudo systemctl disable walinuxagent" | at now + 1 minute
echo -e "sudo ufw deny out from any to 169.254.169.254" | at now + 1 minute