function My-UpgradeChoco {Start-Process powershell.exe -Verb RunAs 'choco upgrade all'}

function My-Find {
    $query = $args[0]
    Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Filter *$query* | %{ $_.FullName }
}

function My-Grep {Get-ChildItem -Recurse | Select-String -Pattern $args[0]}
