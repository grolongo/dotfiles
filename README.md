## Install

### Git

#### HTTPS
```bash
cd $HOME && git clone https://github.com/grolongo/dotfiles.git
```

After syncing SSH keys, do:
```bash
cd $HOME/dotfiles && git remote set-url origin git@github.com:grolongo/dotfiles.git
```

#### SSH
```bash
cd $HOME && git clone git@github.com:grolongo/dotfiles.git
```

### Git-free

#### Linux
```bash
cd $HOME && \
wget -O dotfiles.zip https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip dotfiles.zip && \
mv dotfiles-master dotfiles && \
rm dotfiles.zip
```

#### macOS
```bash
cd $HOME && \
curl -#L -o dotfiles.zip https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip dotfiles.zip && \
mv dotfiles-master dotfiles && \
rm dotfiles.zip
```

#### Windows
```powershell
cd $HOME; `
Invoke-WebRequest -Uri "https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip" -OutFile dotfiles.zip; `
Expand-Archive -Path "dotfiles.zip" -DestinationPath $PWD; `
Rename-Item -Path "dotfiles-master" -NewName "dotfiles"; `
Remove-Item -Path "dotfiles.zip" -Force
```

## Config

#### Linux / macOS
```bash
cd $HOME/dotfiles && \
git config user.name "grolongo" && \
git config user.email "34292770+grolongo@users.noreply.github.com" && \
git config github.user "grolongo"
```

#### Windows
```powershell
cd $HOME/dotfiles; `
git config user.name "grolongo"; `
git config user.email "34292770+grolongo@users.noreply.github.com"; `
git config github.user "grolongo"
```
