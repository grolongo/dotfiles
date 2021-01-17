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

## linux grep functions like
function Get-String {findstr /S /I /P /N $args[0] *}
New-Alias -Name My-Grep -Value Get-String

function Get-String2 {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
New-Alias -Name My-Grep2 -Value Get-String2

## ripgrep
function Get-LocalRipgrep {rg --follow --hidden --max-depth 1 --search-zip --smart-case -e $args[0]}
New-Alias -Name My-LRg -Value Get-LocalRipgrep

function Get-Ripgrep {rg --follow --hidden --search-zip --smart-case $args[0]}
New-Alias -Name My-Rg -Value Get-Ripgrep


