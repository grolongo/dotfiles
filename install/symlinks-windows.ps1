# ------
# README
# ------
# needs PowerShell v4+ (update Windows Management Framework if needed)
# "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" to allow running the script

#Requires -RunAsAdministrator
if ((Get-Location).path -ne $PSScriptRoot) { Write-Output "Exiting. Please cd to the path where the script is located."; exit }

# Dossier racine des dotfiles : "Split-Path" considère le dossier parent par défaut.
New-Variable -Name "base" -Value "$(Split-Path (Get-Location))"

# emacs
# $confirmation = Read-Host "Symlink emacs?"
# if ($confirmation -eq 'y') {
#     New-Item -Force -Path "$env:APPDATA\.emacs.d" -ItemType directory
#     New-Item -Force -Path "$env:APPDATA\.emacs.d\init.el" -ItemType SymbolicLink -Value "$base\.config\emacs\init.el"
#     New-Item -Force -Path "$env:APPDATA\.emacs.d\early-init.el" -ItemType SymbolicLink -Value "$base\.config\emacs\early-init.el"
# }

# mpv
$confirmation = Read-Host "Symlink mpv?"
if ($confirmation -eq 'y') {
    New-Item -Force -Path "$env:APPDATA\mpv" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\mpv\mpv.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\mpv.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\input.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\input.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\scripts" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\mpv\scripts\crop.lua" -ItemType SymbolicLink -Value "$base\.config\mpv\scripts\crop.lua"
    New-Item -Force -Path "$env:APPDATA\mpv\scripts\encode.lua" -ItemType SymbolicLink -Value "$base\.config\mpv\scripts\encode.lua"
    New-Item -Force -Path "$env:APPDATA\mpv\script-opts" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\mpv\script-opts\encode_gif.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\script-opts\encode_gif.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\script-opts\encode_mp4.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\script-opts\encode_mp4.conf"
    New-Item -Force -Path "$env:APPDATA\mpv\script-opts\encode_webm.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\script-opts\encode_webm.conf"
}

# streamlink
$confirmation = Read-Host "Symlink streamlink?"
if ($confirmation -eq 'y') {
    New-Item -Force -Path "$env:APPDATA\streamlink" -ItemType directory
    New-Item -Force -Path "$env:APPDATA\streamlink\config" -ItemType SymbolicLink -Value "$base\.config\streamlink\config"
}

# git
$confirmation = Read-Host "Symlink gitconfig?"
if ($confirmation -eq 'y') {
    New-Item -Force -Path "$HOME\.gitconfig" -ItemType SymbolicLink -Value "$base\.config\git\config"
    #New-Item -Force -Path "$HOME\.gitconfig-windows" -ItemType SymbolicLink -Value "$base\.config\git\config-windows"
}

# aria2
$confirmation = Read-Host "Symlink aria2 conf?"
if ($confirmation -eq 'y') {
    New-Item -Force -Path "$HOME\.aria2" -ItemType directory
    New-Item -Force -Path "$HOME\.aria2\aria2.conf" -ItemType SymbolicLink -Value "$base\.config\aria2\aria2.conf"
}

# powershell profile
$confirmation = Read-Host "Symlink PowerShell profile?"
if ($confirmation -eq 'y') {
    New-Item -Force -Path "$PROFILE" -ItemType SymbolicLink -Value "$base\Microsoft.PowerShell_profile.ps1"
}
