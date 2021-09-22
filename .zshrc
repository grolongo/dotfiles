if [[ -r "$HOME/.aliases" ]] && [[ -f "$HOME/.aliases" ]]; then
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

setopt GLOB_DOTS

# Use compaudit to see insecure folders and fix them.
# Usually just need to fix group writing permissions
# at /usr/local/share/zsh/site-functions etc.
# We also can use "compinit -u" to ignore those warnings
# instead of fixing them (not recommended).

autoload -Uz compinit && compinit -d ~/.cache/zsh/zcompdump

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

    # are we on a remote-tracking branch?
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@"{upstream}" --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n ${remote} ]] ; then
        ahead=$(git rev-list --count ${hook_com[branch]}@"{upstream}"..HEAD 2>/dev/null)
        (( $ahead )) && gitstatus+=( "+${ahead}" )

        behind=$(git rev-list --count HEAD..${hook_com[branch]}@"{upstream}" 2>/dev/null)
        (( $behind )) && gitstatus+=( "-${behind}" )

        hook_com[misc]+=${(j::)gitstatus}
    fi
}

# Emacs vterm
vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

if [ -n "${SSH_TTY}" ] || \
       [ -n "${SSH_CONNECTION}" ] || \
       [ -n "${SSH_CLIENT}" ]; then
    hostStyle="%F{yellow}%m" # yellow
else
    hostStyle="%F{8}%m" # grey
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
