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