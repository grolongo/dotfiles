# linux find functions like
# =========================

function Get-Filename {
    $query = $args[0]
    forfiles /S /M *$query* /C "cmd /c echo @RELPATH"
}
New-Alias -Name My-Find -Value Get-Filename

function Get-Filename2 {
    $query = $args[0]
    Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Filter *$query* | ForEach-Object { $_.FullName }
}
New-Alias -Name My-Find2 -Value Get-Filename2

# linux grep functions like (local and recursive)
# ===============================================

function Get-LocalString {findstr /i /p /n $args[0] *}
New-Alias -Name lfindstr -Value Get-LocalString

function Get-String {findstr /s /i /p /n $args[0] *}
New-Alias -Name rfindstr -Value Get-String

function Get-LocalString2 {Get-ChildItem | Select-String -Pattern $args[0]}
New-Alias -Name lgetchilditem -Value Get-LocalString2

function Get-String2 {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
New-Alias -Name rgetchilditem -Value Get-String2

function Get-LocalRipgrep {rg --follow --hidden --max-depth 1 --search-zip --smart-case -e $args[0]}
New-Alias -Name lrg -Value Get-LocalRipgrep

function Get-Ripgrep {rg --follow --hidden --search-zip --smart-case $args[0]}
New-Alias -Name rrg -Value Get-Ripgrep

# prompt stuff
# ============

# disable cursor blinking
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Output "`e[?12l"
}

function Get-LastStatus() {
    if ($?) {
        return '>'
    } else {
        return "$($PSStyle.Foreground.BrightRed)>$($PSStyle.Reset)"
    }
}

function Get-GitBranch {
    if ((Test-Path .git) -or ((git rev-parse --is-inside-work-tree 2>$null) -eq "true")) {
        $gitBranch = (git branch --show-current 2>$null) ?? (git rev-parse --short HEAD 2>$null)
        return " $($PSStyle.Foreground.BrightCyan)${gitBranch}$($PSStyle.Reset)"
    }
}

function prompt {
    $lastStatus = Get-LastStatus
    $currentDirectory = (Get-Location).path
    $gitBranch = Get-GitBranch
    "${currentDirectory}${gitBranch}${lastStatus} "
}
