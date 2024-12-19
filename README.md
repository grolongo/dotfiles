## Install

### Git

#### HTTPS
```bash
cd ~
git clone https://github.com/grolongo/dotfiles.git
# after syncing ssh files do:
git remote set-url origin git@github.com:grolongo/dotfiles.git
```

#### SSH
```bash
cd ~
git clone git@github.com:grolongo/dotfiles.git
```

### Git-free

#### Linux/macOS
```bash
cd ~
curl -#L https://github.com/grolongo/dotfiles/tarball/master | tar -xzv
# or
wget -O - https://github.com/grolongo/dotfiles/tarball/master | tar -xzv
mv grolongo-dotfiles* dotfiles
```

#### Windows
```powershell
cd $HOME; `
Invoke-WebRequest -Uri "https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip" -OutFile dotfiles.zip; `
Expand-Archive -Path "dotfiles.zip" -DestinationPath .; `
Rename-Item -Path "dotfiles-master" -NewName "dotfiles-trash"; `
Remove-Item -Path "dotfiles.zip" -Force
```

## Config

```bash
cd $HOME/dotfiles
git config user.name "grolongo"
git config user.email "<noreply github email>"
git config github.user "grolongo"
```
