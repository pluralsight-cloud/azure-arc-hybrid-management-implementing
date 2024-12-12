# Create Issues for Troubleshooting, Block outbound traffic and stop the Azure Hybrid Instance Metadata Service
Set-NetFirewallProfile -All -DefaultOutboundAction Block 
Set-Service -Name himds -StartupType Disabled
Stop-Service -Name himds -Force