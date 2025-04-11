# Installation

## with git

#### HTTPS
```bash
git clone https://github.com/grolongo/dotfiles.git "${HOME}/dotfiles"
```

#### SSH
```bash
git clone git@github.com:grolongo/dotfiles.git "${HOME}/dotfiles"
```

## without git

#### Linux
```bash
wget -O dotfiles.tar.gz https://github.com/grolongo/dotfiles/archive/refs/heads/master.tar.gz && \
tar -xvzf dotfiles.tar.gz && \
mv dotfiles-master dotfiles && \
rm dotfiles.tar.gz
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
Then in an Administrator shell: `Set-ExecutionPolicy Bypass`
