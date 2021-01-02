function UpgradeChoco {Start-Process powershell.exe -Verb RunAs 'choco upgrade all'}
function mySelectString {Get-ChildItem -Recurse | Select-String -List $args[0]}

# Highlight Select-String searches
# ================================

function Find-String {
    param	( [string] $pattern = ""
	          , [string] $filter = "*.*"
	          , [switch] $recurse = $false
	          , [switch] $caseSensitive = $false)

    if ($pattern -eq $null -or $pattern -eq "") { Write-Error "Please provide a search pattern!" ; return }

    $regexPattern = $pattern
    if($caseSensitive -eq $false) { $regexPattern = "(?i)$regexPattern" }
    $regex = New-Object System.Text.RegularExpressions.Regex $regexPattern

    # Write the line with the pattern highlighted in red
    function Write-HostAndHighlightPattern([string]$inputText)
    {
	$index = 0
	while($index -lt $inputText.Length)
	{
	    $match = $regex.Match($inputText, $index)
	    if($match.Success -and $match.Length -gt 0)
	    {
		Write-Host $inputText.SubString($index, $match.Index - $index) -nonewline
		Write-Host $match.Value.ToString() -ForegroundColor Red -nonewline
		$index = $match.Index + $match.Length
	    }
	    else
	    {
		Write-Host $inputText.SubString($index) -nonewline
		$index = $inputText.Length
	    }
	}
    }

    # Do the actual find in the files
    Get-ChildItem -recurse:$recurse -filter:$filter | 
      Select-String -caseSensitive:$caseSensitive -pattern:$pattern |	
    foreach {
	Write-Host "$($_.FileName)($($_.LineNumber)): " -nonewline
	Write-HostAndHighlightPattern $_.Line
	Write-Host
    }
}
