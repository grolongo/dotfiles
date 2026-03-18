# Bail out of rest of the setup if we're coming in from Tramp
[ "${TERM}" = "dumb" ] && PS1='$ ' && return

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" ||
            eval "$(dircolors -b)"
fi

### History
shopt -s histappend
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
HISTFILE=~/.cache/bash/history
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=-1
HISTFILESIZE=-1
HISTIGNORE="cd:cd ..:clear:exit:l:ls :pwd"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

### Completion

# only complete directories when using cd
complete -d cd

# needs bash-completion package to use this
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config
# ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" \
                                         -o "nospace" \
                                         -W "$(grep "^Host" ~/.ssh/config | \
                                         grep -v "[?*]" | cut -d " " -f2 | \
                                         tr ' ' '\n')" scp sftp ssh

git_branch() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branchName
        branchName="$(git branch --show-current 2>/dev/null ||
                      git rev-parse --short HEAD 2>/dev/null)"
        printf ' %s' "${branchName}"
    fi
}

set_prompt() {
    # last_exit must be one line
    local last_exit=$?
    local branch
    branch=$(git_branch)

    # highlight the user name when logged in as root
    if [[ "${USER}" == "root" ]]; then
        userStyle="\[\e[1;31m\]" # red
    else
        userStyle="\[\e[1;32m\]" # green
    fi

    # highlight the hostname when connected via SSH
    if [ -n "${SSH_TTY}" ] ||
           [ -n "${SSH_CONNECTION}" ] ||
           [ -n "${SSH_CLIENT}" ]; then
        hostStyle="\[\e[1;33m\]" # yellow
    else
        hostStyle="\[\e[1;32m\]" # green
    fi

    # highlight return code error
    if [[ "$last_exit" == 0 ]]; then
        returnCode="\[\e[1;37m\]" # grey
    else
        returnCode="\[\e[1;31m\]" # red
    fi

    PS1="${userStyle}\u"         # username
    PS1+="\[\e[1;37m\]@"         # @
    PS1+="${hostStyle}\h "       # hostname
    PS1+="\[\e[1;34m\]\w"        # working directory
    PS1+="\[\e[1;36m\]${branch}" # git details
    PS1+="${returnCode} \$"      # $ with return code color
    PS1+="\[\e[0m\] "            # reset colors
}

PROMPT_COMMAND=set_prompt

for file in ~/.{aliases,exports}; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
	    source "$file"
    fi
done
unset file
