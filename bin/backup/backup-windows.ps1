function Compress-Data {
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $browser.description = "Select sync folder to backup:"
    $browser.rootfolder = "MyComputer"
    $null = $browser.ShowDialog()

    $exclude = @(".SynologyWorkingDirectory", "Music")
    $sync_folder = Get-ChildItem -Path $browser.SelectedPath -Exclude $exclude

    $script:zip_file = "$env:temp\backup.zip"

    Write-Output "Compressing sync folders..."
    Compress-Archive -Path $sync_folder -DestinationPath $zip_file -CompressionLevel Fastest

    Write-Output "Adding dotfiles folder to the zip file..."
    Compress-Archive -Path "$HOME/dotfiles" -Update -DestinationPath $zip_file -CompressionLevel Fastest
}

function Invoke-Veracrypt {
    # We use -AsSecureString to hide the password when typing it.
    $pwd1 = Read-Host "Password (use single instead of double quotes)" -AsSecureString
    $pwd2 = Read-Host "Confirm Password" -AsSecureString

    # Retrieving the plain text version of the passwords so we can compare them later.
    $BSTR1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd1)
    $BSTR2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd2)
    $pwd1_clear = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR1)
    $pwd2_clear = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR2)

    # Zero out and free the BSTR to avoid memory leak.
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR1)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR2)

    if ($pwd1_clear -ceq $pwd2_clear) {

        $vc_volume = "$HOME\Desktop\veracrypt_backup.hc"
        $vc_letter = "V"

        Compress-Data

        $zip_size_raw = Get-ChildItem -file $zip_file | ForEach-Object {[math]::ceiling($_.length / 1mb)}
        $zip_size = [int]$zip_size_raw + 5

        Write-Output "Creating container..."
        & "C:\Program Files\VeraCrypt\VeraCrypt Format.exe" `
          /create $vc_volume `
          /size ${zip_size}M `
          /password $pwd1_clear `
          /hash whirlpool `
          /encryption "AES(Twofish(Serpent))" `
          /filesystem FAT `
          /nosizecheck `
          /protectMemory `
          /silent | Out-Null

        Write-Output "Mounting container..."
        & "C:\Program Files\VeraCrypt\VeraCrypt.exe" `
          /hash whirlpool `
          /volume $vc_volume `
          /letter $vc_letter `
          /nowaitdlg yes `
          /password $pwd1_clear `
          /protectMemory `
          /quit `
          /silent | Out-Null

        Write-Output "Copying zip folder to container..."
        Copy-Item $zip_file "${vc_letter}:"

        Write-Output "Dismounting container..."
        & "C:\Program Files\VeraCrypt\VeraCrypt.exe" `
          /dismount $vc_letter `
          /protectMemory `
          /nowaitdlg no `
          /wipecache `
          /quit `
          /silent | Out-Null

        Write-Output "Removing temp zip backup..."
        Remove-Item $zip_file
    }
    else {
        Write-Output "Passwords don't match, aborting."
    }
}

function Invoke-Gnupg {
    $gpg_backup = "$HOME\Desktop\backup.zip.gpg"

    Compress-Data

    Write-Output "Encrypting zip file to $gpg_backup"
    gpg --s2k-mode 3 `
      --s2k-cipher-algo AES256 `
      --s2k-digest-algo SHA512 `
      --s2k-count 65000000 `
      --pinentry-mode=ask `
      --output $gpg_backup `
      --symmetric $zip_file | Out-Null

    Write-Output "Removing temp zip backup..."
    Remove-Item $zip_file
}

function usage {
    Write-Output ""
    Write-Output "Usage: .\backup-windows <cmd>"
    Write-Output "  gnupg"
    Write-Output "  veracrypt"
    Write-Output ""
}

function main {
    $cmd = $args[0]

    # Return error if nothing is specified.
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq "gnupg") { Invoke-Gnupg }
    elseif ($cmd -eq "veracrypt") { Invoke-Veracrypt }
    else { usage }
}

main $args[0]
