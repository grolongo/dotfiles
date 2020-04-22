# aliases
if [[ -r "${HOME}/.aliases" ]] && [[ -f "${HOME}/.aliases" ]]; then
    source "${HOME}/.aliases"
fi

# emacs keybindings
bindkey -e

### PROMPT

setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git

function precmd() { vcs_info }

# if [[ -n $SSH_CONNECTION ]]; then
  # hostStyle="%F{yellow}"
# else
  # hostStyle="%F{green}"
# fi

PROMPT="%(!.%F{red}.%F{green})%n@%m%f %F{blue}%~%f ${vcs_info_msg_0_} %# "
# PROMPT+="$hostStyle%m%f"

### OPTIONS

## Misc
setopt CHASE_LINKS           # cd into the exact symlink path

## Glob
setopt NO_NOMATCH            # bash like no warning on no matching glob files
setopt GLOB_COMPLETE         # when "*", generates matches for completion but not inserts all the results
setopt EXTENDED_GLOB         # enables #, ~ and ^ for filenames generation

## History
setopt APPEND_HISTORY        # sessions append their history to the file rather than replace it
setopt HIST_IGNORE_ALL_DUPS  # deletes any duplicates
setopt HIST_IGNORE_SPACE     # doesnt add <space>ls to the history
setopt SHARE_HISTORY         # imports and appends cmds from different sessions
unsetopt LIST_BEEP           # no beep when no hist entry

### COMPLETION

# using -i to ignore warnings when logging as root
autoload -Uz compinit && compinit -i

# Enables Homebrew zsh-completion package
#fpath=(/usr/local/share/zsh-completions $fpath)

## Options
setopt HASH_LIST_ALL        # hashes cmd path before completion or spelling correction
setopt COMPLETE_IN_WORD     # allow autocomplete from missing characters
setopt GLOB_DOTS            # dont need to insert a "." for completion
setopt NO_BEEP              # no beep on error in ZLE

# Utilise les couleurs de $LS_COLORS pour la completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## General
zstyle ':completion:*' menu select                                          # enables completion list selection
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache true                                       # uses cache file
zstyle ':completion:*' accept-exact-dirs true                               # disables comp. check for existing path
zstyle ':completion:*' select-prompt %SScrolling: %p                        # % counter on long lists
zstyle ':completion:*' completer _complete _correct _approximate            # completers to use (no _ignored)
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'   # no case sensitive

## Display
zstyle ':completion:*' group-name ''                                            # seperates aliases, functions, parameters etc.
zstyle ':completion:*' list-dirs-first true                                     # shows folders before other files
zstyle ':completion:*' auto-description '%d'                                    # ajoute une description automatique pour les options de commande
zstyle ':completion:*:descriptions' format '%B-- %d%b'                          # e.g. -- directory or -- file
zstyle ':completion:*:warnings' format '%F{red}%BNo matches found%b%f'          # e.g. when <TAB> after inexistant folder
zstyle ':completion:*:messages' format '%F{red}%B-- %d%b%f'

## Kill
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=0=01;31"        # kill completion PIDS in red
zstyle ':completion:*:*:*:*:processes' command "ps -u $(whoami) -o pid,user,comm -w -w"  # e.g. "1337 max chromium"

## SSH
h=()
if [[ -r ~/.ssh/config ]]; then
    h=($h ${${${(@M)${(f)"$(< ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi

if [[ $#h -gt 0 ]]; then
    zstyle ':completion:*:(ssh|scp|sftp|slogin):*' hosts $h
fi
