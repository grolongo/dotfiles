## Install

### https

```bash
cd ~
git clone https://github.com/grolongo/dotfiles.git
```

### ssh

```bash
cd ~
git clone git@github.com:grolongo/dotfiles.git
```

### git-free

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

### windows 10 native ssh (instead of Git Bash one)

```powershell
cd dotfiles
git config core.sshCommand "'C:\Windows\System32\OpenSSH\ssh.exe'"
```
