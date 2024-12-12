# Speed up by disabling progress
$ProgressPreference = "SilentlyContinue"

# Set the environment variable to override the ARC on an Azure VM installation
[System.Environment]::SetEnvironmentVariable("MSFT_ARC_TEST",'true', [System.EnvironmentVariableTarget]::Machine)

# Disable the Azure VM Guest Agent
Set-Service WindowsAzureGuestAgent -StartupType Disabled -Verbose
Stop-Service WindowsAzureGuestAgent -Force -Verbose

# Block access to the Azure IMDS endpoint
New-NetFirewallRule -Name BlockAzureIMDS -DisplayName "Block access to Azure IMDS" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 169.254.169.254