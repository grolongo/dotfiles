$pwd1 = Read-Host "Password (use single instead of double quotes)" -AsSecureString
$pwd2 = Read-Host "Confirm Password" -AsSecureString

$BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd1)
$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd2)

$pwd1_clear = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)
$pwd2_clear = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR1)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR2)

$vc_volume = "$HOME\Desktop\backup.hc"
$vc_letter = "X"

function create_container {
  Write-Host "Creating container..."
  & "C:\Program Files\VeraCrypt\VeraCrypt Format.exe" /create $vc_volume /size 210M /password $pwd1_clear /hash whirlpool /encryption "AES(Twofish(Serpent))" /filesystem FAT /silent
}

function open_container {
  Write-Host "Mounting container..."
  & "C:\Program Files\VeraCrypt\VeraCrypt.exe" /hash whirlpool /volume $vc_volume /letter $vc_letter /nowaitdlg /password $pwd1_clear /quit /silent
}

function backup_gpg {
  New-Item -Path "$HOME\AppData\Local\Temp\gnupg-backup-files" -ItemType directory
  Copy-Item "$env:APPDATA\gnupg\private-keys-v1.d" "$HOME\AppData\Local\Temp\gnupg-backup-files" -Recurse
  Copy-Item "$env:APPDATA\gnupg\pubring.kbx" "$HOME\AppData\Local\Temp\gnupg-backup-files"
  # commenting out for now since gpg version on windows is older
  #gpg --export-ownertrust > "$HOME\AppData\Local\Temp\gnupg-backup-files\ownertrust.txt"
}

function backup_ssh {
  New-Item -Path "$HOME\AppData\Local\Temp\ssh-backup-files" -ItemType directory
  Copy-Item "$HOME\.ssh\config" "$HOME\AppData\Local\Temp\ssh-backup-files"
  Copy-Item "$HOME\.ssh\id_rsa" "$HOME\AppData\Local\Temp\ssh-backup-files"
  Copy-Item "$HOME\.ssh\id_rsa-putty.ppk" "$HOME\AppData\Local\Temp\ssh-backup-files"
  Copy-Item "$HOME\.ssh\id_rsa.pub" "$HOME\AppData\Local\Temp\ssh-backup-files"
}

function copy_files {
  Write-Host "Copying files..."
  robocopy /e "$HOME\dotfiles" ${vc_letter}:\dotfiles /xd ".git"
  Copy-Item "$HOME\Seafile\Projects" ${vc_letter}:\ -Recurse
  Copy-Item "$HOME\Seafile\Documents" ${vc_letter}:\ -Recurse
  Copy-Item "$HOME\Seafile\Private" ${vc_letter}:\ -Recurse
  Copy-Item "$HOME\Seafile\Notes" ${vc_letter}:\ -Recurse
  Copy-Item "$HOME\AppData\Local\Temp\gnupg-backup-files" ${vc_letter}:\ -Recurse
  Copy-Item "$HOME\AppData\Local\Temp\ssh-backup-files" ${vc_letter}:\ -Recurse
}

function close_container {
  Write-Host "Dismounting container..."
  & "C:\Program Files\VeraCrypt\VeraCrypt.exe" /dismount x /wipecache /quit /silent
}

if ($pwd1_clear -ceq $pwd2_clear) {
  create_container
  if ($?) {
    Start-Sleep -s 30
    open_container
  }
  if ($?) {
    Start-Sleep -s 30
    backup_gpg
  }
  if ($?) {
    Start-Sleep -s 30
    backup_ssh
  }
  if ($?) {
    Start-Sleep -s 30
    copy_files
  }
  if ($?) {
    Start-Sleep -s 30
    close_container
  }
}
else {
  Write-Host "Passwords don't match, aborting."
}

