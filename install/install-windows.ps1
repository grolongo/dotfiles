# Restriction: use "Set-ExecutionPolicy Unrestricted" as admin to allow this script to be run

#Requires -RunAsAdministrator

### Dotfiles

function set_dotfiles {
    # check if we're in the correct install dir
    if (-not (Test-Path "symlinks-windows.ps1")) { Write-Host -ForegroundColor "red" "Exiting. Please cd into the install directory or make sure symlinks-windows.ps1 is here."; exit }
    .\symlinks-windows
}

### UI Preferences

function set_uipreferences {
    $hiddenext = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    if(Test-Path -Path $hiddenext) {
        Write-Host -ForegroundColor "yellow" "Showing hidden files and file extensions..."
        Set-ItemProperty $hiddenext Hidden 1
        Set-ItemProperty $hiddenext HideFileExt 0
    }

    $righticons = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'

    if(Test-Path -Path $righticons) {
        # show icons notification area (always show = 0, not showing = 1)
        Write-Host -ForegroundColor "yellow" "Setting tray icons..."
        Set-ItemProperty -Path $righticons -Name 'EnableAutoTray' -Value 0
    }

    $mainbar = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    if(Test-Path -Path $mainbar) {
        # taskbar size (small = 1, large = 0)
        Write-Host -ForegroundColor "yellow" "Setting taskbar height size..."
        Set-ItemProperty $mainbar TaskbarSmallIcons 1

        # taskbar combine (always = 0, when full = 1, never = 2)
        Write-Host -ForegroundColor "yellow" "Setting taskbar combine when full mode..."
        Set-ItemProperty $mainbar TaskbarGlomLevel 1

        # lock taskbar (lock = 0, unlock = 1)
        Write-Host -ForegroundColor "yellow" "Locking the taskbar..."
        Set-ItemProperty $mainbar TaskbarSizeMove 0
    }

    Write-Host -ForegroundColor "yellow" "Delog and relog for changes to take effect."
}

### Firewall

function set_firewall {
    $confirmation = Read-Host "yellow" "Block incoming connections and allow outgoing?"
    if ($confirmation -eq 'y') {
        Set-NetConnectionProfile -NetworkCategory Public
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
    }
}

### SSH

function set_ssh {
    Set-Service ssh-agent -StartupType Automatic
}

### Power Saving

function power_settings {
    Write-Host -ForegroundColor "yellow" "Turning off all power saving mode when on AC power..."
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0
    powercfg.exe /HIBERNATE off
}

### Environment Variables

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

### Hostname

function change_hostname {
    $computername = Read-Host -Prompt "What name do you want? (e.g. 'windesk')"
    if ($env:computername -ne $computername) {
	Rename-Computer -NewName $computername
    }

    Write-Host -ForegroundColor "yellow" "Restart to take effect."
}

### Hyper-V

function enable_hyperv {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart
}

### Sandbox

function enable_sandbox {
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
}

### WSL

function get_wsl {
    Write-Host -ForegroundColor "yellow" "Installing Windows Subsystem Linux..."
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart

    Write-Host -ForegroundColor "yellow" "Enabling Virtual Machine Platform for WSL2"
    Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart

    Write-Host -ForegroundColor "yellow" "After reboot: > wsl --set-default-version 2, then follow instructions to update kernel if needed"
    Write-Host -ForegroundColor "yellow" "After setting WSL2, download Debian from the Microsoft Store."
}

### Privacy

function set_privacy {

    Write-Host -ForegroundColor "yellow" "Disabling advertising ID..."

    If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
    }
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

    Write-Host -ForegroundColor "yellow" "Disabling WiFi HotSpot sharing..."

    If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
    }
    Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

    Write-Host -ForegroundColor "yellow" "Disabling Shared HotSpot Auto-Connect..."

    Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

    Write-Host -ForegroundColor "yellow" "Disabling Bing search results..."

    $bing = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    if(!(Test-Path $bing)) {
        New-Item $bing
    }

    New-ItemProperty -LiteralPath $bing -Name "BingSearchEnabled" -Value 0 -PropertyType "DWord" -ErrorAction SilentlyContinue
    Set-ItemProperty -LiteralPath $bing -Name "BingSearchEnabled" -Value 0

    Write-Host -ForegroundColor "yellow" "Disabling Telemetry..."

    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
    Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

    Write-Host -ForegroundColor "yellow" "Disabling Cortana..."

    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Search' -ItemType Key
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0

    Write-Host -ForegroundColor "yellow" "Disabling XBox gamebar..."

    $xbox = "HKCU:\SOFTWARE\Microsoft\GameBar"
    if(!(Test-Path $xbox)) {
        New-Item $xbox
    }

    New-ItemProperty -LiteralPath $xbox -Name "ShowStartupPanel" -Value 0 -PropertyType "DWord" -ErrorAction SilentlyContinue
    Set-ItemProperty -LiteralPath $xbox -Name "ShowStartupPanel" -Value 0

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

    Write-Host -ForegroundColor "yellow" "Reboot for changes to take effect."
}

### Uninstall Bloat

function remove_junk {
    # To list all packages:
    # Get-AppxPackage -AllUsers | Select Name, PackageFullName

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

### Chocolatey

function install_chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

### Packages

function install_packages {
    cinst 7zip
    cinst aria2
    cinst audacity
    cinst chatty
    cinst electrum
    cinst firefox
    cinst gnupg
    cinst itunes
    cinst keepass
    cinst libreoffice
    cinst logitechgaming
    cinst malwarebytes
    cinst mpv
    cinst nextcloud-client
    cinst office365proplus
    cinst onionshare
    cinst pandoc
    cinst seafile-client
    cinst setpoint
    cinst signal
    cinst spotify
    cinst steam
    cinst streamlink
    cinst synologydrive
    cinst thunderbird
    cinst tor-browser
    cinst veracrypt
    cinst vlc
}

### Dev

function install_devtools {
    cinst emacs
    cinst git --params "/GitOnlyOnPath /NoShellIntegration /NoCredentialManager /NoGitLfs /SChannel"
    cinst nodejs
    cinst python

    Write-Host -ForegroundColor "yellow" "installing lsp languages and linters..."
    npm i -g bash-language-server
    cinst shellcheck
    pip install -U setuptools
    pip install python-language-server
    pip install bandit
}

### Menu

function usage {
    Write-Host
    Write-Host "Usage:"
    Write-Host "  dotfiles          - launches external dotfiles script"
    Write-Host "  uipreferences     - windows explorer & taskbar preferences"
    Write-Host "  firewall          - firewall rules: block incoming, allow outgoing"
    Write-Host "  ssh               - automatic startup of ssh agent"
    Write-Host "  powersettings     - disables power saving modes on AC power"
    Write-Host "  envar             - setups environment variables"
    Write-Host "  hostname          - changes hostname"
    Write-Host "  hyperv            - enables native Windows Hyper-V virtualization"
    Write-Host "  sandbox           - enables disposable Windows sandbox"
    Write-Host "  wsl               - installs Windows Subsystem Linux with WSL2"
    Write-Host "  privacy           - wifi hotspot, xbox, etc."
    Write-Host "  remove            - uninstalls unecessary apps"
    Write-Host "  chocolatey        - downloads and sets chocolatey package manager"
    Write-Host "  packages          - downloads and installs listed packages"
    Write-Host "  devtools          - downloads and installs devtools"
    Write-Host
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq "dotfiles") { set_dotfiles }
    elseif ($cmd -eq "uipreferences") { set_uipreferences }
    elseif ($cmd -eq "firewall") { set_firewall }
    elseif ($cmd -eq "ssh") { set_ssh }
    elseif ($cmd -eq "powersettings") { power_settings }
    elseif ($cmd -eq "envar") { install_envar }
    elseif ($cmd -eq "hostname") { change_hostname }
    elseif ($cmd -eq "hyperv") { enable_hyperv }
    elseif ($cmd -eq "sandbox") { enable_sandbox }
    elseif ($cmd -eq "wsl") { get_wsl }
    elseif ($cmd -eq "privacy") { set_privacy }
    elseif ($cmd -eq "remove") { remove_junk }
    elseif ($cmd -eq "chocolatey") { install_chocolatey }
    elseif ($cmd -eq "packages") { install_packages }
    elseif ($cmd -eq "devtools") { install_devtools }
    else { usage }
}

main $args[0]
