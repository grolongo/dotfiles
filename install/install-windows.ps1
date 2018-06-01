# Restriction: use "Set-ExecutionPolicy Unrestricted" as admin to allow this script to be run

#Requires -RunAsAdministrator
# Chocolatey {{{
# ==========

function install_chocolatey {
  Write-Host -ForegroundColor "yellow" 'Downloading and installing chocolatey...'
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# }}}
# Packages {{{
# ========

function install_packages {
  Write-Host -ForegroundColor "yellow" 'Installing packages...'

  # multimedia
  cinst firefox
  cinst thunderbird
  cinst mpv
  cinst streamlink
  cinst spotify
  cinst steam
  cinst itunes
  
  # utilities
  cinst electrum
  cinst gpg4win-vanilla           # needed for enigmail
  cinst keepass
  cinst office365proplus
  cinst libreoffice
  cinst onionshare
  cinst pandoc
  cinst tor-browser
  cinst velocity
  cinst veracrypt
  cinst winrar
  
  # drivers
  cinst logitechgaming
  cinst realtek-hd-audio-driver  # 2.82 wasn't working so may have to download 2.81 from any driver website (which works)
  cinst setpoint

  # dev
  cinst curl                     # for vim-plug in neovim-qt
  cinst git                      # for vim-plug in neovim-qt
  cinst python                   # python3 for neovim-qt
  cinst python2                  # python2 for neovim-qt
  cinst ruby                     # ruby for neovim-qt
  cinst visualstudiocode

  # cloud
  cinst seafile-client

  # scan & cleaners
  cinst adwcleaner
  cinst ccleaner
  cinst hitmanpro
  cinst malwarebytes
}

# }}}
# WSL {{{
# ===

function get_wsl {
  Write-Host -ForegroundColor "yellow" "Installing Windows Subsystem Linux..."
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
  Write-Host -ForegroundColor "yellow" "Now download Debian from Microsoft Store."
}

# }}}
# Wsltty {{{
# ======

function install_wsltty {
  cinst wsltty

  Write-Host -ForegroundColor "yellow" "Installing shortcuts..."
  & "$HOME\AppData\Local\wsltty\configure WSL shortcuts.lnk"
}

# }}}
# Chatty {{{
# ======

function install_chatty {
  $CHATTY_LATEST = Read-Host -Prompt "Enter Chatty version, this can be found on https://github.com/chatty/chatty/releases (ex: 0.9)"
  $REPO = "https://github.com/chatty/chatty/releases/download/"
  $RELEASE = "v$CHATTY_LATEST/Chatty_$CHATTY_LATEST`_windows_standalone.zip"

  Write-Host -ForegroundColor "yellow" "Downloading zip file..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $REPO$RELEASE -OutFile "$HOME\AppData\Local\Temp\chatty.zip"

  Write-Host -ForegroundColor "yellow" "Extracting zip file..."
  Expand-Archive "$HOME\AppData\Local\Temp\chatty.zip" -DestinationPath "C:\Program Files\Chatty"

  Write-Host -ForegroundColor "yellow" "Adding malgun fallback font..."
  Copy-Item "$HOME\dotfiles\fonts\malgun.ttf" -Destination "C:\Program Files\Chatty\runtime\lib\fonts\fallback"
}

# }}}
# Uninstall {{{
# =========
function remove_junk {
  # To list all packages:
  # Get-AppxPackage -AllUsers | Select Name, PackageFullName

  Write-Host -ForegroundColor "yellow" "Removing unecessary bloat..."

  Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
  Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
  Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
  Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
  Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage
  Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage
  Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage
  Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage
  Get-AppxPackage Microsoft.Microsoft3DViewer | Remove-AppxPackage
  Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
  Get-AppxPackage Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage
  Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage
  Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage
  Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage
  Get-AppxPackage Microsoft.People | Remove-AppxPackage
  Get-AppxPackage Microsoft.Print3D | Remove-AppxPackage
  Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
  Get-AppxPackage Microsoft.Wallet | Remove-AppxPackage
  Get-AppxPackage Microsoft.WindowsCamera | Remove-AppxPackage
  Get-AppxPackage Microsoft.WindowsCommunicationsApps | Remove-AppxPackage
  Get-AppxPackage Microsoft.WindowsFeedbackHub | Remove-AppxPackage
  Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage
  Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage
  Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
  Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
  Get-AppxPackage Microsoft.XboxSpeechToTextOverlay | Remove-AppxPackage
  Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
  Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage
  
  Get-AppxPackage *Autodesk* | Remove-AppxPackage
  Get-AppxPackage *BubbleWitch* | Remove-AppxPackage
  Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage
  Get-AppxPackage *Dell* | Remove-AppxPackage
  Get-AppxPackage *Dropbox* | Remove-AppxPackage
  Get-AppxPackage *Facebook* | Remove-AppxPackage
  Get-AppxPackage *Keeper* | Remove-AppxPackage
  Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage
  Get-AppxPackage *McAfee* | Remove-AppxPackage
  Get-AppxPackage *Minecraft* | Remove-AppxPackage
  Get-AppxPackage *Netflix* | Remove-AppxPackage
  Get-AppxPackage *Plex* | Remove-AppxPackage
  Get-AppxPackage *Solitaire* | Remove-AppxPackage
  Get-AppxPackage *Twitter* | Remove-AppxPackage
  
  # Uninstall McAfee Security App
  $mcafee = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "McAfee Security" } | Select-Object UninstallString
  if ($mcafee) {
  	$mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
  	Write-Output -ForegroundColor "yellow" "Uninstalling McAfee..."
  	start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
  }
}
# }}}
# Privacy {{{
# =======

function set_privacy {

  # Let apps use my advertising ID: Disable
  If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
      New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
  }
  Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

  # WiFi Sense: HotSpot Sharing: Disable
  If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
      New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
  }
  Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

  # WiFi Sense: Shared HotSpot Auto-Connect: Disable
  Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0
  
  # Start Menu: Disable Bing Search Results
  $bing = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  if(!(Test-Path $bing)) {
    New-Item $bing
  }

  New-ItemProperty -LiteralPath $bing -Name "BingSearchEnabled" -Value 0 -PropertyType "DWord" -ErrorAction SilentlyContinue
  Set-ItemProperty -LiteralPath $bing -Name "BingSearchEnabled" -Value 0
  
  # Disable Telemetry (requires a reboot to take effect)
  Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
  Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

  # Start Menu: Disable Cortana
  New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Search' -ItemType Key
  New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0
  
  # Disable Xbox Gamebar
  $xbox = "HKCU:\SOFTWARE\Microsoft\GameBar"
  if(!(Test-Path $xbox)) {
      New-Item $xbox
  }

  New-ItemProperty -LiteralPath $xbox -Name "ShowStartupPanel" -Value 0 -PropertyType "DWord" -ErrorAction SilentlyContinue
  Set-ItemProperty -LiteralPath $xbox -Name "ShowStartupPanel" -Value 0

  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

  Write-Host -ForegroundColor "yellow" "Delog and relog for changes to take effect."
}

# }}}
# Network {{{
# =======

function set_network {

  # Firewall
  # --------
  Write-Host -ForegroundColor "yellow" "Setting up firewall..."
  Set-NetConnectionProfile -NetworkCategory Public
  netsh advfirewall set allprofiles state on
  netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound

  # DNS
  # ---
  Write-Host -ForegroundColor "yellow" "Changing Ethernet IPv4 & IPv6 DNS servers to CloudFlare's..."
  Write-Host -ForegroundColor "yellow" "change this script to tweak Ethernet to WiFi if needed."
  Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses "1.1.1.1","1.0.0.1"
  Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses "2606:4700:4700::1111","2606:4700:4700::1001"

}

# }}}
# Explorer {{{
# ========

# options mostly taken from boxstarter winconfig options
function explorer_settings {
  $quickaccess = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
  $hiddenext = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  $fullpath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'

  # Change Explorer home screen back to "This PC"
  Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

  if(Test-Path -Path $quickaccess) {
    Write-Host -ForegroundColor "yellow" "Disabling showing recent and frequent files in quick access..."
    Set-ItemProperty $quickaccess ShowRecent 0
    Set-ItemProperty $quickaccess ShowFrequent 0
  }

  if(Test-Path -Path $hiddenext) {
    Write-Host -ForegroundColor "yellow" "Showing hidden files and file extensions..."
    Set-ItemProperty $hiddenext Hidden 1
    Set-ItemProperty $hiddenext HideFileExt 0
  }

  if(Test-Path -Path $fullpath) {
    Write-Host -ForegroundColor "yellow" "Showing full path in explorer title bar..."
    Set-ItemProperty $fullpath FullPath  1
  }

  Write-Host -ForegroundColor "yellow" "Delog and relog for changes to take effect."
}

# }}}
# Taskbar {{{
# =======

# options mostly taken from boxstarter winconfig options
function taskbar_settings {
  $mainbar = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  $righticons = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
  
  if(Test-Path -Path $righticons) {
    # show icons notification area (always show = 0, not showing = 1)
    Write-Host -ForegroundColor "yellow" "Setting tray icons..."
    Set-ItemProperty -Path $righticons -Name 'EnableAutoTray' -Value 0
  }
  
  if(Test-Path -Path $mainbar) {
    # taskbar size (small = 1, large = 0)
    Write-Host -ForegroundColor "yellow" "Setting taskbar height size..."
    Set-ItemProperty $mainbar TaskbarSmallIcons 1

    # taskbar combine (always = 0, when full = 1, never = 2)
    Write-Host -ForegroundColor "yellow" "Setting combine mode..."
    Set-ItemProperty $mainbar TaskbarGlomLevel 1

    # lock taskbar (lock = 0, unlock = 1)
    Write-Host -ForegroundColor "yellow" "Setting lock..."
    Set-ItemProperty $mainbar TaskbarSizeMove 0
  }

  # Turn off People in Taskbar
  if(-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
  }
  Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

  Write-Host -ForegroundColor "yellow" "Delog and relog for changes to take effect."
}

# }}}
# Power Saving {{{
# ============

function power_settings {
  Write-Host -ForegroundColor "yellow" "Turning off all power saving mode when on AC power..."
  powercfg -change -monitor-timeout-ac 0
  powercfg -change -standby-timeout-ac 0
  powercfg -change -disk-timeout-ac 0
  powercfg -change -hibernate-timeout-ac 0
  powercfg.exe /HIBERNATE off
}

# }}}
# Environment Variables {{{
# =====================

function install_envar {
  $confirmation = Read-Host "yellow" "Appliquer les variables d'environnement ? (pour les dossiers dotfiles, notes et code)"
  if ($confirmation -eq 'y') {
    $cloudpath = Read-Host 'Enter cloud folder path (ex: C:\Users\Bob\Seafile)'
    while (!(Test-path $cloudpath)) {
      $cloudpath = Read-Host 'Invalid path, please re-enter'
    }
    [Environment]::SetEnvironmentVariable('DOTFILES_DIR', "$cloudpath" + "\Dotfiles\", 'User') 
    [Environment]::SetEnvironmentVariable('NOTES_DIR', "$cloudpath" + "\Notes\", 'User') 
    [Environment]::SetEnvironmentVariable('PROJECTS_DIR', "$cloudpath" + "\Code\", 'User') 
  }
}

# }}}
# Rename Computer {{{
# ===============

function rename_pc {
  $computername = Read-Host -Prompt "What name do you want? (e.g. 'windesk')"
  if ($env:computername -ne $computername) {
	  Rename-Computer -NewName $computername
  }
  
  Write-Host -ForegroundColor "yellow" "Restart to take effect."
}

# }}}
# Dotfiles {{{
# ========

function set_dotfiles {

  # check if we're in the correct install dir
  if (-not (Test-Path "symlinks-windows.ps1")) { Write-Host -ForegroundColor "red" "Exiting. Please cd into the install directory or make sure symlinks-windows.ps1 is here."; exit }

  Write-Host -ForegroundColor "yellow" "Launching external symlinks script..."
  .\symlinks-windows
}

# }}}
# Menu {{{
# ====

function usage {
  Write-Host
  Write-Host "Usage:"
  Write-Host "  chocolatey        - downloads and sets chocolatey package manager"
  Write-Host "  packages          - downloads and installs listed packages"
  Write-Host "  wsl               - installs Windows Subsystem Linux"
  Write-Host "  wsltty            - installs Wsltty and shortcuts"
  Write-Host "  chatty            - downloads and installs chatty"
  Write-Host "  remove            - uninstall unecessary apps"
  Write-Host "  privacy           - wifi hotspot, xbox, etc."
  Write-Host "  network           - CloudFlare's DNS servers and firewall settings"
  Write-Host "  explorersettings  - tweaking quick access, show extensions, hidden files in explorer"
  Write-Host "  taskbarsettings   - small taskbar, no combine, show all notification icons, locked"
  Write-Host "  powersettings     - disable power saving modes on AC power"
  Write-Host "  envar             - setups environment variables"
  Write-Host "  rename            - change hostname"
  Write-Host "  dotfiles          - launch external dotfiles script"
  Write-Host
}

function main {
  $cmd = $args[0]

  # return error if nothing is specified
  if (!$cmd) { usage; exit 1 }

  if ($cmd -eq "chocolatey") { install_chocolatey }
  elseif ($cmd -eq "packages") { install_packages }
  elseif ($cmd -eq "wsl") { get_wsl }
  elseif ($cmd -eq "wsltty") { install_wsltty }
  elseif ($cmd -eq "chatty") { install_chatty }
  elseif ($cmd -eq "remove") { remove_junk }
  elseif ($cmd -eq "privacy") { set_privacy }
  elseif ($cmd -eq "network") { set_network }
  elseif ($cmd -eq "explorersettings") { explorer_settings }
  elseif ($cmd -eq "taskbarsettings") { taskbar_settings }
  elseif ($cmd -eq "powersettings") { power_settings }
  elseif ($cmd -eq "envar") { install_envar }
  elseif ($cmd -eq "rename") { rename_pc }
  elseif ($cmd -eq "dotfiles") { set_dotfiles }
  else { usage }
}

main $args[0]

# }}}
