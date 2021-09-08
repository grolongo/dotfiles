# chocolatey
function My-UpgradeChoco {Start-Process powershell.exe -Verb RunAs 'choco upgrade all'}

## linux find functions like
function Get-Filename {
    $query = $args[0]
    forfiles /S /M *$query* /C "cmd /c echo @RELPATH"
}
New-Alias -Name My-Find -Value Get-Filename

function Get-Filename2 {
    $query = $args[0]
    Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Filter *$query* | %{ $_.FullName }
}
New-Alias -Name My-Find2 -Value Get-Filename2

## linux grep functions like (local and recursive)

### using findstr.exe
function Get-LocalString {findstr /i /p /n $args[0] *}
New-Alias -Name lfindstr -Value Get-LocalString

function Get-String {findstr /s /i /p /n $args[0] *}
New-Alias -Name rfindstr -Value Get-String

### using powershell cmdlets
function Get-LocalString2 {Get-ChildItem | Select-String -Pattern $args[0]}
New-Alias -Name lgetchilditem -Value Get-LocalString2

function Get-String2 {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
New-Alias -Name rgetchilditem -Value Get-String2

### using third-party ripgrep
function Get-LocalRipgrep {rg --follow --hidden --max-depth 1 --search-zip --smart-case -e $args[0]}
New-Alias -Name lrg -Value Get-LocalRipgrep

function Get-Ripgrep {rg --follow --hidden --search-zip --smart-case $args[0]}
New-Alias -Name rrg -Value Get-Ripgrep

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
