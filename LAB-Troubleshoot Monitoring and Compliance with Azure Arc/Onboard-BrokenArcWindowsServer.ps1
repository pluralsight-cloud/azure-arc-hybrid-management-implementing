# Speed up Progress
$ProgressPreference = "SilentlyContinue"

# Configure Arc Test
[System.Environment]::SetEnvironmentVariable("MSFT_ARC_TEST",'true', [System.EnvironmentVariableTarget]::Machine)
 
# Install packages
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az.ConnectedMachine -Force
Install-Module Az.Resources -Force
Connect-AzAccount -Identity
 
# Onboard to Azure Arc
$ResourceGroup = Get-AzResourceGroup
Connect-AzConnectedMachine -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "Arc-$($env:COMPUTERNAME)" -Location $ResourceGroup.Location

# Set a Scheduled Task to Create Issues
## Ensure C:\Temp exists
New-Item -Path 'C:\Temp' -ItemType Directory -ErrorAction SilentlyContinue
## Download the Script
Invoke-WebRequest -Uri 'https://gist.githubusercontent.com/WayneHoggett-ACG/237511d78be0229e36b7c91268d960f5/raw/Set-ArcIssues.ps1' -OutFile 'C:\Temp\Set-ArcIssues.ps1'
## Set the Scheduled Task
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Temp\Set-ArcIssues.ps1"
$Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddMinutes(1) -Once 
Register-ScheduledTask -TaskName "Set-ArcIssues" -Action $Action -Trigger $Trigger -Description "Set-ArcIssues" -RunLevel Highest -User "System"  