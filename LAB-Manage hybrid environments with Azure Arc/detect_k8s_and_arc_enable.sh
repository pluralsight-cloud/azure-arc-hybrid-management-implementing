if pgrep -f kubelet > /dev/null 2>&1; then
	echo "kubelet is running - will Arc enable"
	# Install the Azure CLI
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

	# Install K3s
	curl -sfL https://get.k3s.io | sh -

	# Install Helm
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh

	# Install the connectedk8s extension
	az extension add --name connectedk8s

	# Connect to Azure using the Managed Identity
	az login --identity

	# Get the AKS Credentials
	RG=$(az group list --query [].name --output tsv)
	ARCK8S=Arc-Cluster-$(hostname)

	# Arc-enable the AKS Cluster
	az connectedk8s connect --name $ARCK8S --resource-group $RG --distribution k3s --kube-config /etc/rancher/k3s/k3s.yaml
else
	echo "kubelet is not running, will not Arc-enable"
fi