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

```bash
cd ~
curl -#L https://github.com/grolongo/dotfiles/tarball/master | tar -xzv
# or
wget -O - https://github.com/grolongo/dotfiles/tarball/master | tar -xzv
mv grolongo-dotfiles* dotfiles
```

(to update later on, run the command again)

## Config

### default

```bash
cd dotfiles
git config user.name "grolongo"
git config user.email "<noreply github email>"
git config github.user "grolongo"
```
