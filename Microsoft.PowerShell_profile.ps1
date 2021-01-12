function My-UpgradeChoco {Start-Process powershell.exe -Verb RunAs 'choco upgrade all'}

function Get-Filename {
    $query = $args[0]
    Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Filter *$query* | %{ $_.FullName }
}
New-Alias -Name My-Find -Value Get-Filename

function Get-String {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
New-Alias -Name My-Grep -Value Get-String

function Get-LocalRipgrep {rg --follow --hidden --max-depth 1 --search-zip --smart-case -e $args[0]}
New-Alias -Name My-LRg -Value Get-LocalRipgrep

function Get-Ripgrep {rg --follow --hidden --search-zip --smart-case $args[0]}
New-Alias -Name My-Rg -Value Get-Ripgrep
