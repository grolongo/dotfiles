function myChocoUpgrade {Start-Process powershell.exe -Verb RunAs 'choco upgrade all'}

function myFind {
    $query = $args[0]
    Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Filter *$query* | %{ $_.FullName }
}

function myGrep {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
