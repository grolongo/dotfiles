﻿# ------
# README
# ------
# needs PowerShell v4+ (update Windows Management Framework if needed)
# "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" to allow running the script

#Requires -RunAsAdministrator
if ((Get-Location).path -ne $PSScriptRoot) { Write-Output "Exiting. Please cd to the path where the script is located."; exit }

# Dossier racine des dotfiles : "Split-Path" considère le dossier parent par défaut.
New-Variable -Name "base" -Value "$(Split-Path (Get-Location))"

# vim
# ---
$confirmation = Read-Host "Symlink vim?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$HOME\_vimrc" -ItemType SymbolicLink -Value "$base\.vimrc"
}

# neovim
# ------
$confirmation = Read-Host "Symlink neovim?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$HOME\AppData\Local\nvim" -ItemType directory
  New-Item -Force -Path "$HOME\AppData\Local\nvim\init.vim" -ItemType SymbolicLink -Value "$base\.config\nvim\init.vim"
  New-Item -Force -Path "$HOME\AppData\Local\nvim\ultisnippets" -ItemType SymbolicLink -Value "$base\.config\nvim\ultisnippets"
  New-Item -Force -Path "$HOME\AppData\Local\nvim\after" -ItemType directory
  New-Item -Force -Path "$HOME\AppData\Local\nvim\after\syntax" -ItemType SymbolicLink -Value "$base\.config\nvim\after\syntax"
}

# mpv
# ---
$confirmation = Read-Host "Symlink mpv?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$env:APPDATA\mpv" -ItemType directory
  New-Item -Force -Path "$env:APPDATA\mpv\mpv.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\mpv.conf"
  New-Item -Force -Path "$env:APPDATA\mpv\input.conf" -ItemType SymbolicLink -Value "$base\.config\mpv\input.conf"
}

# streamlink
# ----------
$confirmation = Read-Host "Symlink streamlink?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$env:APPDATA\streamlink" -ItemType directory
  New-Item -Force -Path "$env:APPDATA\streamlink\streamlinkrc" -ItemType SymbolicLink -Value "$base\.streamlinkrc"
}

# markdownlinter
# --------------
$confirmation = Read-Host "Symlink mdlrc?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$HOME\.mdlrc" -ItemType SymbolicLink -Value "$base\.mdlrc"
}

# wsltty
# ------
$confirmation = Read-Host "Symlink wsltty?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$env:APPDATA\wsltty\config" -ItemType SymbolicLink -Value "$base\wsltty\config"
  New-Item -Force -Path "$env:APPDATA\wsltty\themes\solarized_dark" -ItemType SymbolicLink -Value "$base\wsltty\themes\solarized_dark"
}

# git
# ---
$confirmation = Read-Host "Symlink gitconfig?"
if ($confirmation -eq 'y') {
  New-Item -Force -Path "$HOME\.gitconfig" -ItemType SymbolicLink -Value "$base\.gitconfig"
}
