# Restriction: use "Set-ExecutionPolicy Bypass" as admin to allow this script to be run

#Requires -RunAsAdministrator

### UI Preferences

function set_uipreferences {
    $explorer = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $exploreradvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $search = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    $explorerpolicies ='HKCU:\\Software\\Policies\\Microsoft\\Windows\\Explorer'
    $theme ='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'

    if(Test-Path -Path $explorer) {
        # show icons notification area (always show = 0, not showing = 1)
        Write-Host -ForegroundColor "yellow" "Showing all tray icons..."
        Set-ItemProperty -Path $explorer -Name 'EnableAutoTray' -Value 0
    }

    if(Test-Path -Path $exploreradvanced) {
        Write-Host -ForegroundColor "yellow" "Showing hidden files and file extensions..."
        Set-ItemProperty -Path $exploreradvanced -Name 'Hidden' -Value 1
        Set-ItemProperty -Path $exploreradvanced -Name 'HideFileExt' -Value 0

        # task view button (show = 1, hide = 0)
        Write-Host -ForegroundColor "yellow" "Hiding task view button..."
        Set-ItemProperty -Path $exploreradvanced -Name 'ShowTaskViewButton' -Value 0

        # taskbar size (small = 1, large = 0)
        Write-Host -ForegroundColor "yellow" "Setting taskbar height size..."
        Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSmallIcons' -Value 1

        # taskbar combine (always = 0, when full = 1, never = 2)
        Write-Host -ForegroundColor "yellow" "Setting taskbar combine when full mode..."
        Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarGlomLevel' -Value 1

        # Win11 icons to the left (center = 1, left = 0)
        Write-Host -ForegroundColor "yellow" "Icons to the left..."
        Set-ItemProperty -Path $exploreradvanced -Name "TaskbarAl" -Value 0

        # lock taskbar (lock = 0, unlock = 1)
        Write-Host -ForegroundColor "yellow" "Locking the taskbar..."
        Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSizeMove' -Value 0

        # disable widgets (on = 1, off = 0)
        Write-Host -ForegroundColor "yellow" "Disabling Taskbar Widgets..."
        Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarDa' -Value 0

        # disable snap assist (on = 1, off = 0)
        Write-Host -ForegroundColor "yellow" "Disabling snap assist..."
        taskkill.exe /F /IM "explorer.exe"
        Set-ItemProperty -Path $exploreradvanced -Name SnapAssist -Value 0
        Start-Process "explorer.exe"
    }

    if(Test-Path -Path $search) {
        # search box (bar = 2, icon = 1, nothing = 0)
        Write-Host -ForegroundColor "yellow" "Removing Cortana search bar..."
        Set-ItemProperty -Path $search -Name 'SearchboxTaskbarMode' -Value 0
    }

    if(!(Test-Path -Path $explorerpolicies)) {
        Write-Host -ForegroundColor "yellow" "Disabling web suggestions in search..."
        New-Item -Path 'HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer' -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer' -Name 'DisableSearchBoxSuggestions' -Type DWord -Value 1 -Force
        Stop-Process -name explorer -force
    }

    if(Test-Path -Path $theme) {
        # dark theme (dark theme = 0, light theme = 1)
        Write-Host -ForegroundColor "yellow" "Enabling dark mode..."
        Set-ItemProperty -Path $theme -Name AppsUseLightTheme -Value 0
        Set-ItemProperty -Path $theme -Name SystemUsesLightTheme -Value 0
    }

    Write-Host -ForegroundColor "yellow" "Disabling sounds..."
    New-ItemProperty -Path HKCU:\AppEvents\Schemes -Name "(Default)" -Value ".None" -Force | Out-Null
    Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps\*\*\.current" | Set-ItemProperty -Name "(Default)" -Value ""

    Write-Host -ForegroundColor "yellow" "Relog for changes to take effect."
}

### Firewall

function set_firewall {
    $confirmation = Read-Host "Block incoming connections and allow outgoing?"
    if ($confirmation -eq 'y') {
        Set-NetConnectionProfile -NetworkCategory Private
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set privateprofile firewallpolicy blockinboundalways,allowoutbound
    }
}

### DNS

function set_dns {
    $confirmation = Read-Host "Set IPv4 & IPv6 DNS servers to Cloudflare?"
    if ($confirmation -eq 'y') {
        Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 1.1.1.1,1.0.0.1
        Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 2606:4700:4700::1111,2606:4700:4700::1001
        Set-DnsClientServerAddress -InterfaceAlias WiFi -ServerAddresses 1.1.1.1,1.0.0.1
        Set-DnsClientServerAddress -InterfaceAlias WiFi -ServerAddresses 2606:4700:4700::1111,2606:4700:4700::1001

        Write-Host -ForegroundColor "yellow" "Flushing DNS cache..."
        Clear-DnsClientCache
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
    $confirmation = Read-Host "Appliquer les variables d'environnement ? (pour les dossiers dotfiles, notes et code)"
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

### Ctrl to Caps

function remap_ctrltocaps {
    $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
    $kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';

    New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);

    Write-Host -ForegroundColor "yellow" "You need to reboot to take effect."
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

function install_choco {
    choco install 7zip
    choco install aria2
    choco install autohotkey
    choco install chatty
    choco install electrum
    choco install emacs
    choco install everything --params "/client-service /efu-association /folder-context-menu /run-on-system-startup /start-menu-shortcuts"
    choco install exiftool
    choco install fd
    choco install ffmpeg
    choco install firefox
    choco install git --params "/GitAndUnixToolsOnPath /NoShellIntegration /NoOpenSSH /NoAutoCrlf /SChannel"
    choco install imagemagick
    choco install keepass
    choco install microsoft-windows-terminal
    choco install mkvtoolnix
    choco install mpv
    choco install nomacs
    choco install obs-studio
    choco install shellcheck
    choco install signal --params "/NoShortcut"
    choco install simplewall
    choco install steam-client
    choco install streamlink
    choco install synologydrive
    choco install telegram
    choco install thunderbird
    choco install tor-browser
    choco install veracrypt
    choco install yt-dlp

    choco pin add -n brave
    choco pin add -n chatty
    choco pin add -n signal
    choco pin add -n simplewall
    choco pin add -n steam-client
    choco pin add -n telegram
    choco pin add -n thunderbird
    choco pin add -n tor-browser
}

### Packages

function install_winget {

    $packages = @(
        "7zip.7zip",
        "aria2.aria2",
        "AutoHotkey.AutoHotkey",
        "Chatty.Chatty",
        "Synology.DriveClient",
        "Electrum.Electrum",
        "GNU.Emacs",
        "voidtools.Everything",
        "OliverBetz.ExifTool",
        "sharkdp.fd",
        "Gyan.FFmpeg",
        "Mozilla.Firefox",
        "Git.Git",
        "XavierRoche.HTTrack",
        "ImageMagick.ImageMagick",
        "DominikReichl.KeePass",
        "GnuWin32.Make",
        "MoritzBunkus.MKVToolNix",
        "MullvadVPN.MullvadVPN",
        "Insecure.Nmap",
        "nomacs.nomacs",
        "OBSProject.OBSStudio",
        "Microsoft.PowerToys",
        "Python.Python.3.12",
        "BurntSushi.ripgrep.MSVC",
        "koalaman.shellcheck",
        "OpenWhisperSystems.Signal",
        "Henry++.simplewall",
        "Spotify.Spotify",
        "Valve.Steam",
        "Streamlink.Streamlink",
        "Telegram.TelegramDesktop",
        "TorProject.TorBrowser",
        "IDRIX.VeraCrypt",
        "Microsoft.VisualStudioCode",
        "Microsoft.WindowsTerminal",
        "yt-dlp.yt-dlp"
    )

    Write-Host -ForegroundColor "yellow" "Updating sources list..."
    winget source update

    foreach ($p in $packages) {
        do {
            $response = Read-Host "Install '$p'? [y/n]"
            $response = $response.ToLower()
            if ($response -ne "y" -and $response -ne "n") {
                Write-Host -ForegroundColor "yellow" "Please enter 'y' or 'n'"
            }
        } while ($response -ne "y" -and $response -ne "n")

        if ($response -eq "y") {
            winget install "$p"
        }
    }
}

### qBittorrent

function install_qbittorrent {
    # choco install qbittorrent
    winget install qBittorrent.qBittorrent

    New-Variable -Name "PLUGIN_FOLDER" -Value "$HOME\AppData\Local\qBittorrent\nova3\engines"
    New-Item -Force -Path "$PLUGIN_FOLDER" -ItemType directory

    ## RARBG and ThePirateBay should already be installed by default

    Invoke-WebRequest -Uri "https://gist.githubusercontent.com/BurningMop/fa750daea6d9fa86c8fe5d686f12ed35/raw/16397ff605b1e2f60c70379166c3e7f8df28867d/one337x.py" -OutFile "$PLUGIN_FOLDER\one337x.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py" -OutFile "$PLUGIN_FOLDER\ettv.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py" -OutFile "$PLUGIN_FOLDER\glotorrents.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py" -OutFile "$PLUGIN_FOLDER\kickasstorrents.py"
    Invoke-WebRequest -Uri "https://scare.ca/dl/qBittorrent/magnetdl.py" -OutFile "$PLUGIN_FOLDER\magnetdl.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py" -OutFile "$PLUGIN_FOLDER\linuxtracker.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py" -OutFile "$PLUGIN_FOLDER\rutor.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py" -OutFile "$PLUGIN_FOLDER\tokyotoshokan.py"
    Invoke-WebRequest -Uri "https://scare.ca/dl/qBittorrent/torrentdownload.py" -OutFile "$PLUGIN_FOLDER\torrentdownload.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py" -OutFile "$PLUGIN_FOLDER\torrentgalaxy.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MaurizioRicci/qBittorrent_search_engine/master/yts_am.py" -OutFile "$PLUGIN_FOLDER\yts_am.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py" -OutFile "$PLUGIN_FOLDER\rutracker.py"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py" -OutFile "$PLUGIN_FOLDER\yggtorrent.py"
}

### OneDrive

function remove_onedrive {

    # taken from Chris Titus script

    $OneDrivePath = $($env:OneDrive)
    Write-Host \"Removing OneDrive\"
    $regPath = \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OneDriveSetup.exe\"

    if (Test-Path $regPath){
        $OneDriveUninstallString = Get-ItemPropertyValue \"$regPath\" -Name \"UninstallString\"
        $OneDriveExe, $OneDriveArgs = $OneDriveUninstallString.Split(\" \")
        Start-Process -FilePath $OneDriveExe -ArgumentList \"$OneDriveArgs /silent\" -NoNewWindow -Wait
    }
    else{
        Write-Host \"Onedrive dosn't seem to be installed anymore\" -ForegroundColor Red
        return
    }

    # Check if OneDrive got Uninstalled
    if (-not (Test-Path $regPath)){
        Write-Host \"Copy downloaded Files from the OneDrive Folder to Root UserProfile\"
        Start-Process -FilePath powershell -ArgumentList \"robocopy '$($OneDrivePath)' '$($env:USERPROFILE.TrimEnd())\\' /mov /e /xj\" -NoNewWindow -Wait

        Write-Host \"Removing OneDrive leftovers\"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue \"$env:localappdata\\Microsoft\\OneDrive\"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue \"$env:localappdata\\OneDrive\"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue \"$env:programdata\\Microsoft OneDrive\"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue \"$env:systemdrive\\OneDriveTemp\"
        reg delete \"HKEY_CURRENT_USER\\Software\\Microsoft\\OneDrive\" -f
        # check if directory is empty before removing:
        If ((Get-ChildItem \"$OneDrivePath\" -Recurse | Measure-Object).Count -eq 0) {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue \"$OneDrivePath\"
        }

        Write-Host \"Remove Onedrive from explorer sidebar\"
        Set-ItemProperty -Path \"HKCR:\\CLSID\\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\" -Name \"System.IsPinnedToNameSpaceTree\" -Value 0
        Set-ItemProperty -Path \"HKCR:\\Wow6432Node\\CLSID\\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\" -Name \"System.IsPinnedToNameSpaceTree\" -Value 0

        Write-Host \"Removing run hook for new users\"
        reg load \"hku\\Default\" \"C:\\Users\\Default\\NTUSER.DAT\"
        reg delete \"HKEY_USERS\\Default\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\" /v \"OneDriveSetup\" /f
        reg unload \"hku\\Default\"

        Write-Host \"Removing startmenu entry\"
        Remove-Item -Force -ErrorAction SilentlyContinue \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\OneDrive.lnk\"

        Write-Host \"Removing scheduled task\"
        Get-ScheduledTask -TaskPath '\\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

        # Add Shell folders restoring default locations
        Write-Host \"Shell Fixing\"
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"AppData\" -Value \"$env:userprofile\\AppData\\Roaming\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Cache\" -Value \"$env:userprofile\\AppData\\Local\\Microsoft\\Windows\\INetCache\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Cookies\" -Value \"$env:userprofile\\AppData\\Local\\Microsoft\\Windows\\INetCookies\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Favorites\" -Value \"$env:userprofile\\Favorites\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"History\" -Value \"$env:userprofile\\AppData\\Local\\Microsoft\\Windows\\History\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Local AppData\" -Value \"$env:userprofile\\AppData\\Local\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"My Music\" -Value \"$env:userprofile\\Music\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"My Video\" -Value \"$env:userprofile\\Videos\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"NetHood\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Network Shortcuts\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"PrintHood\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Printer Shortcuts\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Programs\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Recent\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Recent\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"SendTo\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\SendTo\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Start Menu\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Startup\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Templates\" -Value \"$env:userprofile\\AppData\\Roaming\\Microsoft\\Windows\\Templates\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"{374DE290-123F-4565-9164-39C4925E467B}\" -Value \"$env:userprofile\\Downloads\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Desktop\" -Value \"$env:userprofile\\Desktop\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"My Pictures\" -Value \"$env:userprofile\\Pictures\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"Personal\" -Value \"$env:userprofile\\Documents\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"{F42EE2D3-909F-4907-8871-4C22FC0BF756}\" -Value \"$env:userprofile\\Documents\" -Type ExpandString
        Set-ItemProperty -Path \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders\" -Name \"{0DDD015D-B06C-45D5-8C4C-F59713854639}\" -Value \"$env:userprofile\\Pictures\" -Type ExpandString
        Write-Host \"Restarting explorer\"
        taskkill.exe /F /IM \"explorer.exe\"
        Start-Process \"explorer.exe\"

        Write-Host \"Waiting for explorer to complete loading\"
        Write-Host \"Please Note - The OneDrive folder at $OneDrivePath may still have items in it. You must manually delete it, but all the files should already be copied to the base user folder.\"
        Write-Host \"If there are Files missing afterwards, please Login to Onedrive.com and Download them manually\" -ForegroundColor Yellow
        Start-Sleep 5
    }
    else{
        Write-Host \"Something went Wrong during the Unistallation of OneDrive\" -ForegroundColor Red
    }
}

### Copilot

function remove_copilot {
    Write-Host -ForegroundColor "yellow" "Removing Copilot..."
    dism /online /remove-package /package-name:Microsoft.Windows.Copilot
}

### Dotfiles

function set_dotfiles {
    # check if we're in the correct install dir
    if (-not (Test-Path "symlinks-windows.ps1")) { Write-Host -ForegroundColor "red" "Exiting. Please cd into the install directory or make sure symlinks-windows.ps1 is here."; exit }
    .\symlinks-windows
}

### Menu

function usage {
    Write-Host
    Write-Host "Usage:"
    Write-Host "  uipreferences     - windows explorer & taskbar preferences"
    Write-Host "  firewall          - firewall rules: block incoming, allow outgoing"
    Write-Host "  dns               - IPv4 & IPv6 DNS to Cloudflare for Ethernet and WiFi"
    Write-Host "  ssh               - automatic startup of ssh agent"
    Write-Host "  powersettings     - disables power saving modes on AC power"
    Write-Host "  envar             - setups environment variables"
    Write-Host "  hostname          - changes hostname"
    Write-Host "  features          - enables Hyper-V and Disposable Desktop"
    Write-Host "  ctrltocaps        - remap CTRL key to Caps Lock"
    Write-Host "  wsl               - enables WSL2 and installs Ubuntu or Debian"
    Write-Host "  chocolatey        - downloads and sets chocolatey package manager"
    Write-Host "  choco_packages    - downloads and installs listed packages with chocolatey"
    Write-Host "  winget_packages   - downloads and installs listed packages with winget"
    Write-Host "  qbit              - installs qBittorrent with plugins"
    Write-Host "  onedrive          - removes OneDrive entirely"
    Write-Host "  copilot           - removes Copilot entirely"
    Write-Host "  dotfiles          - launches external dotfiles script"
Write-Host
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq "uipreferences") { set_uipreferences }
    elseif ($cmd -eq "firewall") { set_firewall }
    elseif ($cmd -eq "dns") { set_dns }
    elseif ($cmd -eq "ssh") { set_ssh }
    elseif ($cmd -eq "powersettings") { power_settings }
    elseif ($cmd -eq "envar") { install_envar }
    elseif ($cmd -eq "hostname") { change_hostname }
    elseif ($cmd -eq "features") { enable_wof }
    elseif ($cmd -eq "ctrltocaps") {remap_ctrltocaps}
    elseif ($cmd -eq "wsl") { install_wsl }
    elseif ($cmd -eq "chocolatey") { install_chocolatey }
    elseif ($cmd -eq "choco_packages") { install_choco }
    elseif ($cmd -eq "winget_packages") { install_winget }
    elseif ($cmd -eq "qbit") { install_qbittorrent }
    elseif ($cmd -eq "onedrive") { remove_onedrive }
    elseif ($cmd -eq "copilot") { remove_copilot }
    elseif ($cmd -eq "dotfiles") { set_dotfiles }
    else { usage }
}

main $args[0]
