# External files
for file in ~/.{aliases,exports}; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
        . "$file"
    fi
done

# Emacs keybinds
bindkey -e

# Disable the log builtin, so we don't conflict with /usr/bin/log
disable log

setopt CHASE_LINKS # cd into the exact symlink path
unsetopt BEEP

### History

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=9999
SAVEHIST=9999
HISTORY_IGNORE="(cd|cd ..|clear|exit|l|ls |pwd)"

setopt HIST_IGNORE_SPACE # doesnt add <space>ls to the history
setopt HIST_NO_STORE     # doesnt add history cmd to the history
setopt HIST_IGNORE_DUPS  # doesnt add cmd if duplicate as previous event
setopt SHARE_HISTORY

### Completion

# using -i to ignore warnings when logging as root
autoload -Uz compinit && compinit -i

# Enables Homebrew zsh-completion package
#fpath=(/usr/local/share/zsh-completions $fpath)

## Options
setopt GLOB_DOTS            # dont need to insert a "." for completion

# Utilise les couleurs de $LS_COLORS pour la completion
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

## General
zstyle ':completion:*' use-cache true
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' select-prompt '%p'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*:descriptions' format '%B-- %d%b'
zstyle ':completion:*:warnings' format 'no matches found'
zstyle ':completion:*:processes' command "ps -u $(whoami) -o pid,user,comm -w -w"

## SSH

# hide login names because we dont need them
zstyle ':completion:*:ssh:argument-1:*' tag-order hosts

# only pick hostnames from our ssh config file
h=()
if [[ -r ~/.ssh/config ]]; then
    h=($h ${${${(@M)${(f)"$(< ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi

if [[ $#h -gt 0 ]]; then
    zstyle ':completion:*:(ssh|scp|sftp|slogin):*' hosts $h
fi

### Prompt

setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' stagedstr '+'
zstyle ':vcs_info:git*' unstagedstr '!'
zstyle ':vcs_info:git*' formats ' %b%u%c%m'
zstyle ':vcs_info:git*' actionformats ' (%a) %b%u%c%m'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stash git-st

function +vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
           git status --porcelain | grep '??' &> /dev/null ; then
        hook_com[unstaged]+='?'
    fi
}

function +vi-git-stash() {
    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        hook_com[misc]+='$'
    fi
}

function +vi-git-st() {
    local ahead behind remote
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n ${remote} ]] ; then
        ahead=$(git rev-list --count ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null)
        (( $ahead )) && gitstatus+=( "+${ahead}" )

        behind=$(git rev-list --count HEAD..${hook_com[branch]}@{upstream} 2>/dev/null)
        (( $behind )) && gitstatus+=( "-${behind}" )

        hook_com[misc]+=${(j::)gitstatus}
    fi
}

# Highlight the hostname when connected via SSH.
if [ -n "${SSH_TTY}" ] || \
   [ -n "${SSH_CONNECTION}" ] || \
   [ -n "${SSH_CLIENT}" ]; then
    hostStyle="%F{yellow}%m"       # yellow
else
    hostStyle="%F{8}%m"            # grey
fi

function precmd() { vcs_info }

PROMPT='%B['
PROMPT+='%(!.%F{red}.%F{green})%n%f'
PROMPT+='@'
PROMPT+='$hostStyle '
PROMPT+='%F{blue}%~%f'
PROMPT+='%F{cyan}${vcs_info_msg_0_}%f'
PROMPT+=']'
PROMPT+='%# '
PROMPT+='%b%E'
