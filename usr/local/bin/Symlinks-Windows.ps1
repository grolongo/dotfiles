# "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" to allow running the script
#Requires -RunAsAdministrator

function Get-Version {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        if ($PSCmdlet.ShouldContinue('Launch PowerShell 7?', 'This script requires PowerShell 7+.')) {
            $powershellLocation = Join-Path (Join-Path (Join-Path "$env:ProgramFiles" "PowerShell") "7") "pwsh.exe"
            if (-Not (Test-Path -Path $powershellLocation)) {
                Write-Output 'PowerShell 7 not found, install PowerShell 7 first.'
                exit 1
            } else {
                Start-Process -FilePath $powershellLocation -WorkingDirectory $PSScriptRoot -ArgumentList "-NoExit", $PSCommandPath
                exit
            }
        } else {
            exit 1
        }
    }
}

$dotfilesRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent

function Set-Emacs {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking Emacs config.')) {
        $emacsConfigDirectory = Join-Path -Path $env:APPDATA -ChildPath '.emacs.d'

        New-Item -Force -Path $emacsConfigDirectory -ItemType directory

        New-Item -Force -Path (Join-Path -Path $emacsConfigDirectory -ChildPath 'init.el') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'emacs', 'init.el')

        New-Item -Force -Path (Join-Path -Path $emacsConfigDirectory -ChildPath 'early-init.el') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'emacs', 'early-init.el')

        takeown /f $emacsConfigDirectory /r
    }
}

function Set-MPV {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking mpv config files.')) {
        $mpvConfigDirectory = Join-Path -Path $env:APPDATA -ChildPath 'mpv'

        New-Item -Force -Path $mpvConfigDirectory -ItemType directory

        New-Item -Force -Path (Join-Path -Path $mpvConfigDirectory -ChildPath 'mpv.conf') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'mpv', 'mpv.conf')

        New-Item -Force -Path (Join-Path -Path $mpvConfigDirectory -ChildPath 'input.conf') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'mpv', 'input.conf')

        New-Item -Force -Path (Join-Path -Path $mpvConfigDirectory -ChildPath 'scripts' -AdditionalChildPath 'osctoggle.lua') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'mpv', 'scripts', 'osctoggle.lua')

        New-Item -Force -Path (Join-Path -Path $mpvConfigDirectory -ChildPath 'script-opts') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'mpv', 'script-opts')
        takeown /f $mpvConfigDirectory /r
    }
}

function Set-Streamlink {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking Streamlink config file.')) {
        $streamlinkConfigDirectory = Join-Path -Path $env:APPDATA -ChildPath 'streamlink'

        New-Item -Force -Path $streamlinkConfigDirectory -ItemType directory

        New-Item -Force -Path (Join-Path -Path $streamlinkConfigDirectory -ChildPath 'config') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'streamlink', 'config')

        takeown /f $streamlinkConfigDirectory /r
    }
}

function Set-Git {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking Git config files.')) {
        New-Item -Force -Path (Join-Path -Path $env:USERPROFILE -ChildPath '.gitconfig') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'git', 'config')

        New-Item -Force -Path (Join-Path -Path $env:USERPROFILE -ChildPath '.gitconfig-windows') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'git', 'config-windows')

        takeown /f (Join-Path -Path $env:USERPROFILE -ChildPath '.gitconfig')
        takeown /f (Join-Path -Path $env:USERPROFILE -ChildPath '.gitconfig-windows')
    }
}

function Set-Aria2 {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking aria2 config file.')) {
        $ariaConfigDirectory = Join-Path -Path $env:USERPROFILE -ChildPath '.aria2'

        New-Item -Force -Path $ariaConfigDirectory -ItemType directory

        New-Item -Force -Path (Join-Path -Path $ariaConfigDirectory -ChildPath 'aria2.conf') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath '.config' -AdditionalChildPath 'aria2', 'aria2.conf')

        takeown /f $ariaConfigDirectory /r
    }
}

function Set-Autohotkey {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking AutoHotKey script.')) {
        New-Item -Force -Path (Join-Path -Path $env:APPDATA -ChildPath Microsoft -AdditionalChildPath 'Windows', 'Start Menu', 'Programs', 'Startup', 'keybinds-shortcuts.ahk') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath 'usr' -AdditionalChildPath 'local', 'bin', 'keybinds-shortcuts.ahk')

        takeown /f (Join-Path -Path $env:APPDATA -ChildPath Microsoft -AdditionalChildPath 'Windows', 'Start Menu', 'Programs', 'Startup', 'keybinds-shortcuts.ahk')
    }
}

function Set-PowerShell {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldContinue('Continue?', 'Symlinking PowerShell profile.')) {
        # powershell v4
        New-Item -Force -Path (Join-Path -Path $env:USERPROFILE -ChildPath 'Documents' -AdditionalChildPath 'WindowsPowerShell', 'Microsoft.PowerShell_profile.ps1') -ItemType SymbolicLink `
          -Value (Join-Path -Path $dotfilesRoot -ChildPath 'Microsoft.PowerShell_profile.ps1')

        # powershell v7
        New-Item -Force -Path $PROFILE -ItemType SymbolicLink -Value (Join-Path -Path $dotfilesRoot -ChildPath 'Microsoft.PowerShell_profile.ps1')

        takeown /f (Join-Path -Path $env:USERPROFILE -ChildPath 'Documents' -AdditionalChildPath 'WindowsPowershell') /r
    }
}

Get-Version
# Set-Emacs
Set-MPV
Set-Streamlink
Set-Git
Set-Aria2
Set-Autohotkey
Set-PowerShell
