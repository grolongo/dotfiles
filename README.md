## Install

### HTTPS

```bash
cd ~
git clone https://github.com/grolongo/dotfiles.git
```

### SSH

```bash
cd ~
git clone git@github.com:grolongo/dotfiles.git
```

### Git-free

`curl -#L https://github.com/grolongo/dotfiles/tarball/master | tar -xzv`  
(to update later on, run the command again)

## Config

### default

```bash
cd dotfiles
git config user.name "grolongo"
git config user.email "<noreply github email>"
git config github.user "grolongo"
```

### Windows 10 native SSH (instead of Git for Windows one)

```powershell
git config --global core.sshCommand "'C:\Windows\System32\OpenSSH\ssh.exe'"
```
