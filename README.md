# Installation

## Linux/macOS

#### Git (HTTPS)
```bash
git clone https://github.com/grolongo/dotfiles.git "${HOME}/git/dotfiles"
```

#### Git (SSH)
```bash
git clone git@github.com:grolongo/dotfiles.git "${HOME}/git/dotfiles"
```

#### Wget
```bash
tmpdir=$(mktemp -d); trap 'rm -rf "${tmpdir}"' EXIT && \
mkdir -vp "${HOME}/git" && \
wget -O "${tmpdir}/dotfiles.tar.gz" https://github.com/grolongo/dotfiles/archive/refs/heads/master.tar.gz && \
tar -xvzf "${tmpdir}/dotfiles.tar.gz" -C "${HOME}/git" && \
mv "${HOME}/git/dotfiles-master" "${HOME}/git/dotfiles"
```

#### cURL
```bash
tmpdir=$(mktemp -d); trap 'rm -rf "${tmpdir}"' EXIT && \
mkdir -vp "${HOME}/git" && \
curl -#L -o "${tmpdir}/dotfiles.zip" https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip "${tmpdir}/dotfiles.zip" -d "${HOME}"/git && \
mv "${HOME}/git/dotfiles-master" "${HOME}/git/dotfiles"
```

## Windows

#### Git (HTTPS)
```powershell
$cloneLocation = Join-Path -Path $env:USERPROFILE -ChildPath 'git' -AdditionalChildPath 'dotfiles'; `
git clone https://github.com/grolongo/dotfiles.git $cloneLocation
```

#### Git (SSH)
```powershell
$cloneLocation = Join-Path -Path $env:USERPROFILE -ChildPath 'git' -AdditionalChildPath 'dotfiles'; `
git clone git@github.com:grolongo/dotfiles.git $cloneLocation
```

#### Invoke-WebRequest
```powershell
$dotfilesUrl = "https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip"; `
$downloadLocation = Join-Path -Path $env:TEMP -ChildPath 'dotfiles.zip'; `
$installLocation = Join-Path -Path $env:USERPROFILE -ChildPath 'git'; `
$currentName = Join-Path -Path $env:USERPROFILE -ChildPath 'git' -AdditionalChildPath 'dotfiles-master'; `
$newName = Join-Path -Path $env:USERPROFILE -ChildPath 'git' -AdditionalChildPath 'dotfiles'; `
Invoke-WebRequest -Uri $dotfilesUrl -OutFile $downloadLocation; `
Expand-Archive -Path $downloadLocation -DestinationPath $installLocation; `
Rename-Item -Path $currentName -NewName $newName; `
Remove-Item $downloadLocation
```
Then in an Administrator shell: `Set-ExecutionPolicy Bypass`
