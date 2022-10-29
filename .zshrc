if [ -r "$HOME/.aliases" ] && [ -f "$HOME/.aliases" ]; then
    . "$HOME/.aliases"
fi

setopt CHASE_LINKS # cd into the exact symlink path
unsetopt BEEP

### History
HISTSIZE=9999
HISTFILE=~/.cache/zsh/history
SAVEHIST=9999
HISTORY_IGNORE="(cd|cd ..|clear|exit|l|ls |pwd)"
setopt HIST_IGNORE_SPACE # doesnt add <space>ls to the history
setopt HIST_NO_STORE     # doesnt add history cmd to the history
setopt HIST_IGNORE_DUPS  # doesnt add cmd if duplicate as previous event
setopt SHARE_HISTORY

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

### Completion

# Use compaudit to see insecure folders and fix them.
# Usually just need to fix group writing permissions
# at /usr/local/share/zsh/site-functions etc.
# We also can use "compinit -u" to ignore those warnings
# instead of fixing them (not recommended).

autoload -Uz compinit && compinit -d ~/.cache/zsh/zcompdump
_comp_options+=(globdots) # include hidden files on <tab>

# On GNU Linux with coreutils, just uses dircolors
# as expected with the variable $LS_COLORS and default
# values.
# On BSD without dircolors, we declare $LS_COLORS with
# the default color syntax used by dircolors because zsh
# isn't compatible with $LSCOLORS (which is what BSD uses).

if whence dircolors >/dev/null; then
    eval "$(dircolors -b)"
else
    export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
fi

zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache true
# zstyle cache-path "~/.cache/zsh/zcompcache"
zstyle ':completion::complete:*' cache-path "$HOME/.cache/zsh/zcompcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' select-prompt '%p'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*:descriptions' format '%B-- %d%b'
zstyle ':completion:*:warnings' format 'no match found'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,user,%cpu,comm,cmd'

## SSH command

# hide login names because we dont need them
zstyle ':completion:*:ssh:argument-1:*' tag-order hosts

# only pick hostnames from our ssh config file

h=()
if [ -r ~/.ssh/config ]; then
    h=($h ${${${(@M)${(f)"$(< ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi

if [ $#h -gt 0 ]; then
    zstyle ':completion:*:(ssh|scp|sftp|slogin):*' hosts $h
fi

### Prompt

setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes false
zstyle ':vcs_info:git*' check-for-staged-changes false
zstyle ':vcs_info:git*' formats ' %b'

function precmd() {
    vcs_info
}

# Hostname coloring local/remote
if [ -n "${SSH_TTY}" ] || \
       [ -n "${SSH_CONNECTION}" ] || \
       [ -n "${SSH_CLIENT}" ]; then
    hostStyle="%F{yellow}%m" # yellow
else
    hostStyle="%F{8}%m" # grey
fi

PROMPT='%B%(!.%F{red}.%F{green})%n%f'
PROMPT+='@'
PROMPT+='$hostStyle '
PROMPT+='%F{blue}%~%f'
PROMPT+='%F{cyan}${vcs_info_msg_0_}%f'
PROMPT+=' %# '
PROMPT+='%b%E'
