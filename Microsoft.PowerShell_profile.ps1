# history
# =======

$MaximumHistoryCount = 30000
Set-PSReadLineOption -MaximumHistoryCount 1000000000
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistoryNoDuplicates

function Search-History {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$searchPattern
    )

    $historyPath = (Get-PSReadlineOption).HistorySavePath
    Get-Content -Path $historyPath | Select-String -Pattern $searchPattern -SimpleMatch
}

New-Alias -Name hist -Value Search-History

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

# extra
# =====

function Search-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$searchPattern
    )

    process {
        Get-ChildItem -Path '.' -Recurse -FollowSymlink -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Filter "*$searchPattern*" | Select-Object -ExpandProperty FullName
    }
}

function Search-File2 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$searchPattern
    )

    fd.exe --follow --hidden $searchPattern
}

function Search-FileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$searchPattern,
        [switch]$Recurse
    )

    Get-ChildItem -Path '.' -FollowSymlink -Force -File -Recurse:$Recurse |
      Where-Object {
          try {
              $stream = [System.IO.File]::OpenRead($_.FullName)
              $buffer = New-Object byte[] 1024
              $read = $stream.Read($buffer, 0, 1024)
              $stream.Close()
              $slice = $buffer[0..($read - 1)]
              -not ($slice | Where-Object { $_ -lt 9 -or ($_ -gt 13 -and $_ -lt 32) })
          } catch {
              $false
          }
          finally {
              if ($stream) { $stream.Dispose() }
          }
      } | Select-String -Pattern $searchPattern -SimpleMatch
}

function Search-FileContent2 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$searchPattern,
        [switch]$Recurse
    )

    $flags = @('/i', '/p', '/n')
    if ($Recurse) { $flags += '/s' }
    findstr.exe @flags $searchPattern *
}

function Search-FileContent3 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$searchPattern,
        [switch]$Recurse
    )

    $flags = @('--follow', '--hidden', '--search-zip', '--smart-case')
    if (-not $Recurse) { $flags += '--max-depth', '1' }
    $flags += '-e'
    rg.exe @flags $searchPattern
}

function Send-Stuff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ Test-Path $_ })]
        [string]$filePath
    )

    scp $filePath x230:/home/grolongo/Downloads/
}

New-Alias -Name scpp -Value Send-Stuff
