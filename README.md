## Install

### Git

#### HTTPS
```bash
git clone https://github.com/grolongo/dotfiles.git
```

After syncing SSH keys, do:
```bash
git remote set-url origin git@github.com:grolongo/dotfiles.git
```

#### SSH
```bash
git clone git@github.com:grolongo/dotfiles.git
```

### Git-free

#### Linux
```bash
wget -O dotfiles.zip https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip dotfiles.zip && \
mv dotfiles-master dotfiles && \
rm dotfiles.zip
```

#### macOS
```bash
curl -#L -o dotfiles.zip https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip dotfiles.zip && \
mv dotfiles-master dotfiles && \
rm dotfiles.zip
```

#### Windows
```powershell
Invoke-WebRequest -Uri "https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip" -OutFile dotfiles.zip; `
Expand-Archive -Path "dotfiles.zip" -DestinationPath $PWD; `
Rename-Item -Path "dotfiles-master" -NewName "dotfiles"; `
Remove-Item -Path "dotfiles.zip" -Force
```
