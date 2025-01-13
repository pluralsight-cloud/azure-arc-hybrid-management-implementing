# Speed up by disabling progress
$ProgressPreference = "SilentlyContinue"

# Clean-up Edge
## Create the Directory Tree
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\PasswordManagerEnabled" -Force
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" -Force
# Disable full-tab promotional content
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
## Disable Password Manager
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge\PasswordManagerEnabled" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
## Disallow importing of browser settings
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportBrowserSettings" -Value 0 -Force
## Disallow Microsoft News content on the new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled" -Value 0 -Type "DWord" -Force
## Disallow all background types allowed for the new tab page layout
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAllowedBackgroundTypes" -Value 3 -Type "DWord" -Force
## Hide App Launcher on Microsoft Edge new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAppLauncherEnabled" -Value 0 -Type "DWord" -Force
## Disable the password manager
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PasswordManagerEnabled" -Value '0' -Force
## Hide the First-run experience and splash screen
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1 -Force
## Disable sign-in
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "BrowserSignin" -Value 0 -Force
## Disable quick links on the new tab page
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "NewTabPageQuickLinksEnabled" -Value 0 -Force
## Disable importing of favorites
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportFavorites" -Value 0 -Force
 
#Disable IE ESC
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
 
# Clean-up System Tray
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideClock" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableNotificationCenter" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAVolume" -Value 1
 
# Disable Server Manager
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

# Set Network Profile to Private and enable network discovery
Set-NetConnectionProfile -NetworkCategory Private
Get-NetFirewallRule -DisplayGroup 'Network Discovery' | Set-NetFirewallRule -Profile 'Private' -Enabled true
 
# Download SQL Server Trial
New-Item -Path "C:\" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2215202&clcid=0x409&culture=en-us&country=us" -OutFile "C:\Temp\SQL2022-SSEI-Eval.exe"
Set-Location -Path "C:\Temp"

# Install SQL Server
## Create a new local user and add it to the Administrators group
$Password = New-Guid
$Username = "SQLInstaller"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
New-LocalUser -Name $Username -Password $SecurePassword
Add-LocalGroupMember -Group Administrators -Member $Username

## Set a Scheduled Task to Install SQL Server
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command C:\Temp\SQL2022-SSEI-Eval.exe /IAcceptSqlServerLicenseTerms /Quiet /Action=Install /Language=en-US"
$Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddMinutes(1) -Once
Register-ScheduledTask -TaskName "Install-SQLServer" -Action $Action -Trigger $Trigger -Description "Install-SQLServer" -RunLevel Highest -User $Username -Password $Password 

# Wait until at least the SQL Server service exists before continuing
While (-not (Get-Service -Name 'MSSQLSERVER' -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 5
}

# Set a Scheduled Task to Disable the Azure VM Guest Agent and the Azure IMDS endpoint
## Ensure C:\Temp exists
New-Item -Path 'C:\Temp' -ItemType Directory -ErrorAction SilentlyContinue
## Download the Script
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pluralsight-cloud/azure-arc-hybrid-management-implementing/refs/heads/main/LAB-Manage%20SQL%20Server%20with%20Azure%20Arc/Disable-AzureAgent.ps1' -OutFile 'C:\Temp\Disable-AzureAgent.ps1'
## Set the Scheduled Task
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Temp\Disable-AzureAgent.ps1"
$Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddMinutes(1) -Once 
Register-ScheduledTask -TaskName "Disable-AzureAgent" -Action $Action -Trigger $Trigger -Description "Disable-AzureAgent" -RunLevel Highest -User "System"  