# ------
# README
# ------
# needs PowerShell v4+ (update Windows Management Framework if needed)
# "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" to allow running the script

#Requires -RunAsAdministrator
if ((Get-Location).path -ne $PSScriptRoot) { Write-Output "Exiting. Please cd to the path where the script is located."; exit }

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

# root dotfiles folder : "Split-Path" considers parent folder as default
New-Variable -Name "base" -Value ((Get-Location).Path -replace "(\\[^\\]+){3}$", "")

# emacs
# if (Ask-Question 'Symlink Emacs?') {
#     New-Item -Force -Path "$env:APPDATA\.emacs.d" -ItemType directory
#     New-Item -Force -Path "$env:APPDATA\.emacs.d\init.el" -ItemType SymbolicLink -Value "$base\.config\emacs\init.el"
#     New-Item -Force -Path "$env:APPDATA\.emacs.d\early-init.el" -ItemType SymbolicLink -Value "$base\.config\emacs\early-init.el"
# }

# mpv
if (Ask-Question 'Symlink mpv?') {
    New-Item -Force -Path "$env:APPDATA\mpv" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\mpv\mpv.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\mpv.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\input.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\input.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\scripts\osctoggle.lua" -ItemType SymbolicLink -Value "$base\.config\mpv\scripts\osctoggle.lua"
    New-Item -Force -Path "$env:APPDATA\mpv\script-opts" -ItemType SymbolicLink -Value "$base\.config\mpv\script-opts"
    takeown /f "$env:APPDATA\mpv" /r
}

# streamlink
if (Ask-Question 'Symlink streamlink?') {
    New-Item -Force -Path "$env:APPDATA\streamlink" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\streamlink\config" -ItemType SymbolicLink -Value "$base\.config\streamlink\config"
    takeown /f "$env:APPDATA\streamlink" /r
}

# git
if (Ask-Question 'Symlink gitconfig?') {
    New-Item -Force -Path "$HOME\.gitconfig" -ItemType SymbolicLink -Value "$base\.config\git\config"
    New-Item -Force -Path "$HOME\.gitconfig-windows" -ItemType SymbolicLink -Value "$base\.config\git\config-windows"
    takeown /f "$HOME\.gitconfig"
    takeown /f "$HOME\.gitconfig-windows"
}

# aria2
if (Ask-Question 'Symlink aria2?') {
    New-Item -Force -Path "$HOME\.aria2" -ItemType directory
    New-Item -Force -Path "$HOME\.aria2\aria2.conf" -ItemType SymbolicLink -Value "$base\.config\aria2\aria2.conf"
    takeown /f "$HOME\.aria2" /r
}

# autohotkey
if (Ask-Question 'Symlink AutoHotKey scripts?') {
    New-Item -Force -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\keybinds-shortcuts.ahk" -ItemType SymbolicLink -Value "$base\usr\local\bin\keybinds-shortcuts.ahk"
    takeown /f "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\keybinds-shortcuts.ahk"
}

# powershell profile
if (Ask-Question 'Symlink PowerShell profile?') {
    # powershell v4
    New-Item -Force -Path "$PROFILE" -ItemType SymbolicLink -Value "$base\Microsoft.PowerShell_profile.ps1"
    # powershell v7
    New-Item -Force -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -ItemType SymbolicLink -Value "$base\Microsoft.PowerShell_profile.ps1"
    takeown /f "$HOME\Documents\WindowsPowershell" /r
}
