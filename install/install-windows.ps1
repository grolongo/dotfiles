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

### Windows Optional Features

function enable_wof {
    # Hyper-V
    Write-Host -ForegroundColor "yellow" "Enabling Microsoft Hyper-V..."
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart

    # Disposable Virtual Desktop
    Write-Host -ForegroundColor "yellow" "Enabling Windows Disposable Container Desktop..."
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
}

### WSL

function install_wsl {
    # to change default Ubuntu: "wsl.exe --install -d Debian"
    wsl.exe --install
}

### Chocolatey

function install_chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}


### Packages

function install_packages {
    choco install 7zip
    choco install aria2
    choco install chatty
    choco install electrum
    choco install emacs
    choco install everything --params "/client-service /efu-association /folder-context-menu /run-on-system-startup /start-menu-shortcuts"
    choco install ffmpeg
    choco install git --params "/GitAndUnixToolsOnPath /NoShellIntegration /NoOpenSSH /NoAutoCrlf /SChannel"
    choco install imagemagick
    choco install librewolf
    choco install keepass
    choco install microsoft-windows-terminal
    choco install mpv
    choco install nomacs
    choco install obs-studio
    choco install shellcheck
    choco install signal --params "/NoShortcut"
    choco install steam-client
    choco install streamlink
    choco install synologydrive
    choco install thunderbird
    choco install tor-browser
    choco install veracrypt
    choco install youtube-dl

    choco pin add -n chatty
    choco pin add -n librewolf
    choco pin add -n signal
    choco pin add -n steam
    choco pin add -n tor-browser
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
    Write-Host "  features          - enables several Windows Optional Features (WSL)"
    Write-Host "  wsl               - enables WSL2 and installs Ubuntu or Debian"
    Write-Host "  chocolatey        - downloads and sets chocolatey package manager"
    Write-Host "  packages          - downloads and installs listed packages"
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
    elseif ($cmd -eq "features") { enable_wof }
    elseif ($cmd -eq "wsl") { install_wsl }
    elseif ($cmd -eq "chocolatey") { install_chocolatey }
    elseif ($cmd -eq "packages") { install_packages }
    else { usage }
}

main $args[0]
