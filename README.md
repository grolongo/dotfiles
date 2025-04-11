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
wget -O "${HOME}/dotfiles.tar.gz" https://github.com/grolongo/dotfiles/archive/refs/heads/master.tar.gz && \
tar -xvzf "${HOME}/dotfiles.tar.gz" -C "${HOME}" && \
mv "${HOME}/dotfiles-master" "${HOME}/dotfiles" && \
rm "${HOME}/dotfiles.tar.gz"
```

#### macOS
```bash
curl -#L -o "${HOME}/dotfiles.zip" https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip && \
unzip "${HOME}/dotfiles.zip" -d "${HOME}" && \
mv "${HOME}/dotfiles-master" "${HOME}/dotfiles" && \
rm "${HOME}/dotfiles.zip"
```

#### Windows
```powershell
Invoke-WebRequest -Uri "https://github.com/grolongo/dotfiles/archive/refs/heads/master.zip" -OutFile "${HOME}/dotfiles.zip"; `
Expand-Archive -Path "${HOME}/dotfiles.zip" -DestinationPath "${HOME}"; `
Rename-Item -Path "${HOME}/dotfiles-master" -NewName "${HOME}/dotfiles"; `
Remove-Item -Path "${HOME}/dotfiles.zip" -Force
```
Then in an Administrator shell: `Set-ExecutionPolicy Bypass`
