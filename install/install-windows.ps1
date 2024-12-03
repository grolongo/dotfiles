# Restriction: use "Set-ExecutionPolicy Bypass" as admin to allow this script to be run

#Requires -RunAsAdministrator

### Common functions

function Ask-Question {
    param(
        [Parameter(Mandatory=$true)]
        [string]$question
    )
    do {
        $response = Read-Host "$question [y/n]"
        $response = $response.ToLower()
        switch ($response) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Host "Please enter 'y' or 'n'"
            }
        }
    } while ($response -ne 'y' -and $response -ne 'n')
}

function Write-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    Write-Host -ForegroundColor 'yellow' $message
}

### UI/UX Preferences

function set_uipreferences {
    $explorer = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $exploreradvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    # show icons notification area (always show = 0, not showing = 1)
    Write-Message 'Showing all tray icons...'
    Set-ItemProperty -Path $explorer -Name 'EnableAutoTray' -Value 0

    # taskbar size (small = 1, large = 0)
    Write-Message 'Setting taskbar height size...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSmallIcons' -Value 1

    # taskbar combine (always = 0, when full = 1, never = 2)
    Write-Message 'Setting taskbar combine when full mode...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarGlomLevel' -Value 1

    # lock taskbar (lock = 0, unlock = 1)
    Write-Message 'Locking the taskbar...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSizeMove' -Value 0

    # disable recent files, folders and cloud files (hidden = 0, show = 1)
    Write-Message 'Disabling recent files and folders...'
    Set-ItemProperty -Path $exploreradvanced -Name 'CloudFilesOnDemand' -Value 0
    Set-ItemProperty -Path $exploreradvanced -Name 'Start_TrackDocs' -Value 0
    Set-ItemProperty -Path $explorer -Name 'ShowFrequent' -Value 0

    # Start menu layout
    Write-Message 'Setting up the Start menu...'
    Set-ItemProperty -Path $exploreradvanced -Name 'Start_Layout' -Value 1 # (1 = More pins, 2 = More recommendations, 3 = Default)

    # disable transparency (1 = enabled, 0 = disabled)
    Write-Message 'Disabling transparency effects...'
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0

    # screenshot folder
    Write-Message 'Setting the screenshot folder to Desktop...'
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}' -Value "$env:USERPROFILE\Desktop"

    # excluding folders from AV scans
    Write-Message 'Excluding Emacs from AV scanning...'
    Add-MpPreference -ExclusionPath 'C:\Program Files\Emacs', "$env:APPDATA\.emacs.d"

    if (Ask-Question 'Set time zone?') {
        Set-TimeZone -Name 'Romance Standard Time'
    }

    Stop-Process -Name explorer -Force
    Write-Message 'Relog for changes to take effect.'
}

### No sound

function set_nosound {
    Write-Message 'Switching Sound Scheme to no sounds...'
    New-ItemProperty -Path 'HKCU:\AppEvents\Schemes' -Name '(Default)' -Value '.None' -Force | Out-Null
    Get-ChildItem -Path 'HKCU:\AppEvents\Schemes\Apps' -Recurse | Where-Object { $_.PSChildName -eq '.Current' } | Set-ItemProperty -Name '(Default)' -Value ''

    Write-Message 'Turning Windows Startup sound off...'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'DisableStartupSound' -Value 1 -Type DWord -Force
}

### Firewall

function set_firewall {
    if (Ask-Question 'Block incoming connections and allow outgoing?') {
        Set-NetConnectionProfile -NetworkCategory Private
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set privateprofile firewallpolicy blockinboundalways,allowoutbound
    }
}

### SSH

function set_ssh {
    Set-Service ssh-agent -StartupType Automatic
}

### Power Saving

function power_settings {
    Write-Message 'Turning off all power saving mode when on AC power...'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0
    if (Ask-Question 'Turn hibernate off (if on a laptop, answer no)?') {
        powercfg.exe /HIBERNATE off
    }
}

### Environment Variables

function install_envar {
    $cloudpath = Read-Host 'Enter cloud folder path (ex: C:\Users\Bob\Seafile)'
    while (!(Test-path $cloudpath)) {
        $cloudpath = Read-Host 'Invalid path, please re-enter'
    }
    [Environment]::SetEnvironmentVariable('DOTFILES_DIR', "$cloudpath" + "\Dotfiles\", 'User')
    [Environment]::SetEnvironmentVariable('NOTES_DIR', "$cloudpath" + "\Notes\", 'User')
    [Environment]::SetEnvironmentVariable('PROJECTS_DIR', "$cloudpath" + "\Code\", 'User')
}

### Hostname

function change_hostname {
    $computername = Read-Host -Prompt 'What name do you want? (e.g. ''windesk'')'
    if ($env:computername -ne $computername) {
        Rename-Computer -NewName $computername
    }

    Write-Message 'Restart to take effect.'
}

### Ctrl to Caps

function remap_ctrltocaps {
    $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
    $kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';

    New-ItemProperty -Path $kbLayout -Name 'Scancode Map' -PropertyType Binary -Value ([byte[]]$hexified);

    Write-Message 'You need to reboot to take effect.'
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
    choco install everything --params '/client-service /efu-association /folder-context-menu /run-on-system-startup /start-menu-shortcuts'
    choco install exiftool
    choco install fd
    choco install ffmpeg
    choco install firefox
    choco install git --params '/GitAndUnixToolsOnPath /NoShellIntegration /NoOpenSSH /NoAutoCrlf /SChannel'
    choco install imagemagick
    choco install keepass
    choco install microsoft-windows-terminal
    choco install mkvtoolnix
    choco install mpv
    choco install nomacs
    choco install obs-studio
    choco install shellcheck
    choco install signal --params '/NoShortcut'
    choco install simplewall
    choco install soundswitch
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
        '7zip.7zip',
        'aria2.aria2',
        'AutoHotkey.AutoHotkey',
        'Chatty.Chatty',
        'Synology.DriveClient',
        'Electrum.Electrum',
        'GNU.Emacs',
        'voidtools.Everything',
        'OliverBetz.ExifTool',
        'sharkdp.fd',
        'FeatherWallet.Feather',
        'Gyan.FFmpeg',
        'Mozilla.Firefox',
        'XavierRoche.HTTrack',
        'GnuPG.GnuPG',
        'ImageMagick.ImageMagick',
        'DominikReichl.KeePass',
        'GnuWin32.Make',
        'MoritzBunkus.MKVToolNix',
        'Microsoft.MouseandKeyboardCenter',
        'MullvadVPN.MullvadVPN',
        'Insecure.Nmap',
        'nomacs.nomacs',
        'OBSProject.OBSStudio',
        'Microsoft.PowerToys',
        'Python.Python.3.12',
        'BurntSushi.ripgrep.MSVC',
        'koalaman.shellcheck',
        'OpenWhisperSystems.Signal',
        'Henry++.simplewall',
        'AntoineAflalo.SoundSwitch',
        'Spotify.Spotify',
        'Valve.Steam',
        'Streamlink.Streamlink',
        'Telegram.TelegramDesktop',
        'TorProject.TorBrowser',
        'IDRIX.VeraCrypt',
        'Oracle.VirtualBox',
        'Microsoft.VisualStudioCode',
        'Microsoft.WindowsTerminal',
        'yt-dlp.yt-dlp'
    )

    Write-Message 'Updating sources list...'
    winget source update

    foreach ($p in $packages) {
        if (Ask-Question "Install ${p}?") { winget install -e --id "$p" }
    }

    if (Ask-Question 'Install Git?') { winget install -e --id Git.Git --custom '/o:Components=icons,gitlfs /o:PathOption:CmdTools /o:SSHOption=ExternalOpenSSH /o:CRLFOption:CRLFCommitAsIs /o:CURLOption=WinSSL' }
}

### mpv

function install_mpv {
    Write-Message "Creating variables and folders..."

    New-Variable -Name 'mpvInstallPath' -Value 'C:\Program Files\mpv'
    New-Variable -Name 'mpvConfigPath' -Value "$env:APPDATA\mpv"

    New-Item -Force -Path "$mpvInstallPath" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\fonts" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\scripts" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\scripts\uosc" -ItemType directory

    Write-Message "Installing latest mpv..."

    Start-BitsTransfer -Source 'https://sourceforge.net/projects/mpv-player-windows/files/bootstrapper.zip' -Destination "$mpvInstallPath\bootstrapper.zip"
    Expand-Archive -Path "$mpvInstallPath\bootstrapper.zip" -DestinationPath "$mpvInstallPath"

    Write-Message "Adding mpv to path..."
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$mpvInstallPath", [EnvironmentVariableTarget]::User)

    Push-Location "$mpvInstallPath"
    & "$mpvInstallPath\updater.ps1"
    Pop-Location

    Remove-Item "$mpvInstallPath\bootstrapper.zip"

    Write-Message "Installing plugins..."

    Start-BitsTransfer -Source 'https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip' -Destination "$mpvConfigPath\uosc.zip"
    Expand-Archive -Path "$mpvConfigPath\uosc.zip" -DestinationPath "$mpvConfigPath"

    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua' -OutFile "$mpvConfigPath\scripts\thumbfast.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua' -OutFile "$mpvConfigPath\scripts\visualizer.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua' -OutFile "$mpvConfigPath\scripts\crop.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua' -OutFile "$mpvConfigPath\scripts\encode.lua"

    Remove-Item "$mpvConfigPath\uosc.zip"
}

### qBittorrent

function install_qbittorrent {
    # choco install qbittorrent
    winget install qBittorrent.qBittorrent

    New-Variable -Name 'PLUGIN_FOLDER' -Value "$HOME\AppData\Local\qBittorrent\nova3\engines"
    New-Item -Force -Path "$PLUGIN_FOLDER" -ItemType directory

    # Official plugins
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/eztv.py'                                           -OutFile "$PLUGIN_FOLDER\eztv.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/limetorrents.py'                                   -OutFile "$PLUGIN_FOLDER\limetorrents.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/piratebay.py'                                      -OutFile "$PLUGIN_FOLDER\piratebay.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/solidtorrents.py'                                  -OutFile "$PLUGIN_FOLDER\solidtorrents.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torlock.py'                                        -OutFile "$PLUGIN_FOLDER\torlock.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentproject.py'                                 -OutFile "$PLUGIN_FOLDER\torrentproject.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentscsv.py'                                    -OutFile "$PLUGIN_FOLDER\torrentscsv.py"

    # Third Party
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py'                                           -OutFile "$PLUGIN_FOLDER\bitsearch.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/therarbg.py'                                            -OutFile "$PLUGIN_FOLDER\therarbg.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/torrentdownloads.py'                                    -OutFile "$PLUGIN_FOLDER\torrentdownloads.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py'                                -OutFile "$PLUGIN_FOLDER\ettv.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py'                         -OutFile "$PLUGIN_FOLDER\glotorrents.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py'                     -OutFile "$PLUGIN_FOLDER\kickasstorrents.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/snowfl.py'                              -OutFile "$PLUGIN_FOLDER\snowfl.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/dodi_repacks.py'                                                      -OutFile "$PLUGIN_FOLDER\dodi_repacks.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/fitgirl_repacks.py'                                                   -OutFile "$PLUGIN_FOLDER\fitgirl_repacks.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py' -OutFile "$PLUGIN_FOLDER\linuxtracker.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py'                                         -OutFile "$PLUGIN_FOLDER\nyaasi.py"
    Invoke-WebRequest -Uri 'https://scare.ca/dl/qBittorrent/torrentdownload.py'                                                                                  -OutFile "$PLUGIN_FOLDER\torrentdownload.py"
    Invoke-WebRequest -Uri 'https://scare.ca/dl/qBittorrent/magnetdl.py'                                                                                         -OutFile "$PLUGIN_FOLDER\magnetdl.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py'                                                              -OutFile "$PLUGIN_FOLDER\rutor.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py'                                       -OutFile "$PLUGIN_FOLDER\rutracker.py"
    Invoke-WebRequest -Uri 'https://gist.githubusercontent.com/scadams/56635407b8dfb8f5f7ede6873922ac8b/raw/f654c10468a0b9945bec9bf31e216993c9b7a961/one337x.py' -OutFile "$PLUGIN_FOLDER\one337x.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AlaaBrahim/qBitTorrent-animetosho-search-plugin/main/animetosho.py'                                -OutFile "$PLUGIN_FOLDER\animetosho.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TuckerWarlock/qbittorrent-search-plugins/main/bt4gprx.com/bt4gprx.py'                              -OutFile "$PLUGIN_FOLDER\bt4gprx.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MarcBresson/cpasbien/master/src/cpasbien.py'                                                       -OutFile "$PLUGIN_FOLDER\cpasbien.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py'                          -OutFile "$PLUGIN_FOLDER\tokyotoshokan.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py'                                                  -OutFile "$PLUGIN_FOLDER\torrentgalaxy.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/menegop/qbfrench/master/torrent9.py'                                                               -OutFile "$PLUGIN_FOLDER\torrent9.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/amongst-us/qbit-plugins/main/yts_mx/yts_mx.py'                                                     -OutFile "$PLUGIN_FOLDER\yts_mx.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/444995/qbit-search-plugins/main/engines/zooqle.py'                                                 -OutFile "$PLUGIN_FOLDER\zooqle.py"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py'                                        -OutFile "$PLUGIN_FOLDER\yggtorrent.py"
}

### Dotfiles

function set_dotfiles {
    # check if we're in the correct install dir
    if (-not (Test-Path 'symlinks-windows.ps1')) { Write-Host -ForegroundColor 'red' 'Exiting. Please cd into the install directory or make sure symlinks-windows.ps1 is here.'; exit }
    .\symlinks-windows
}

### CTT Windows Utility

function run_winutil {
    irm 'https://christitus.com/win' | iex
}

### Menu

function usage {
    Write-Host
    Write-Host 'Usage:'
    Write-Host '  uipreferences     - windows explorer & taskbar preferences'
    Write-Host '  nosound           - applies no sounds scheme and turn off startup sound'
    Write-Host '  firewall          - firewall rules: block incoming, allow outgoing'
    Write-Host '  ssh               - automatic startup of ssh agent'
    Write-Host '  powersettings     - disables power saving modes on AC power'
    Write-Host '  envar             - setups environment variables'
    Write-Host '  hostname          - changes hostname'
    Write-Host '  ctrltocaps        - remap CTRL key to Caps Lock'
    Write-Host '  chocolatey        - downloads and sets chocolatey package manager'
    Write-Host '  choco_packages    - downloads and installs listed packages with chocolatey'
    Write-Host '  winget_packages   - downloads and installs listed packages with winget'
    Write-Host '  mpv               - installs mpv'
    Write-Host '  qbit              - installs qBittorrent with plugins'
    Write-Host '  dotfiles          - launches external dotfiles script'
    Write-Host '  winutil           - runs Chris Titus Techs Windows Utility'
    Write-Host
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq 'uipreferences') { set_uipreferences }
    elseif ($cmd -eq 'nosound') { set_nosound }
    elseif ($cmd -eq 'firewall') { set_firewall }
    elseif ($cmd -eq 'ssh') { set_ssh }
    elseif ($cmd -eq 'powersettings') { power_settings }
    elseif ($cmd -eq 'envar') { install_envar }
    elseif ($cmd -eq 'hostname') { change_hostname }
    elseif ($cmd -eq 'ctrltocaps') {remap_ctrltocaps}
    elseif ($cmd -eq 'chocolatey') { install_chocolatey }
    elseif ($cmd -eq 'choco_packages') { install_choco }
    elseif ($cmd -eq 'winget_packages') { install_winget }
    elseif ($cmd -eq 'mpv') { install_mpv }
    elseif ($cmd -eq 'qbit') { install_qbittorrent }
    elseif ($cmd -eq 'dotfiles') { set_dotfiles }
    elseif ($cmd -eq 'winutil') { run_winutil }
    else { usage }
}

main $args[0]
