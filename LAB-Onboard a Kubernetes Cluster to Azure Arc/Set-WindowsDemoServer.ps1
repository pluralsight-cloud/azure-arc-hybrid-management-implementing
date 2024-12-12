# Ensure the process runs quickly
$ProgressPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

# Disable Server Manager
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

# Hide Notification Area (System Tray)
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoTrayItemsDisplay" 1

# Clean-up Microsoft Edge
# Create the Directory Tree
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\PasswordManagerEnabled" -Force
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" -Force
# Disable full-tab promotional content
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
# Disable Password Manager
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge\PasswordManagerEnabled" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
# Disallow importing of browser settings
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportBrowserSettings" -Value 0 -Force
# Disallow Microsoft News content on the new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled" -Value 0 -Type "DWord" -Force
# Disallow all background types allowed for the new tab page layout
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAllowedBackgroundTypes" -Value 3 -Type "DWord" -Force
# Hide App Launcher on Microsoft Edge new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAppLauncherEnabled" -Value 0 -Type "DWord" -Force
# Disable the password manager
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PasswordManagerEnabled" -Value '0' -Force
# Hide the First-run experience and splash screen
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1 -Force
# Disable sign-in
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "BrowserSignin" -Value 0 -Force
# Disable quick links on the new tab page
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "NewTabPageQuickLinksEnabled" -Value 0 -Force
# Disable importing of favorites
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportFavorites" -Value 0 -Force

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Import Chocolately Profile
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# Update Environmental Variables
Update-SessionEnvironment

# Configure Software
choco install zoomit -y --no-progress
choco install vscode -y --no-progress
choco install azure-cli -y --no-progress
choco install kubernetes-cli -y --no-progress