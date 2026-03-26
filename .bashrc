# bail out of rest of the setup if we're coming in from Tramp
if [[ "${TERM}" == "dumb" ]]; then
    PS1='$ '
    return
fi

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
if [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# enable color support
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(/usr/bin/dircolors -b ~/.dircolors)"
    else
        eval "$(/usr/bin/dircolors -b)"
    fi
fi

# history
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

# only complete directories when using cd
complete -d cd

# needs bash-completion package to use this
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# add tab completion for SSH hostnames based on ~/.ssh/config
# ignoring wildcards
if [[ -e "$HOME/.ssh/config" ]]; then
    complete -o "default" \
             -o "nospace" \
             -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" \
             scp sftp ssh
fi

git_branch() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branchname
        branchname="$(git branch --show-current 2>/dev/null ||
                      git rev-parse --short HEAD 2>/dev/null)"
        printf ' %s' "${branchname}"
    fi
}

set_prompt() {
    # last_exit must be a single line, and first
    local last_exit=$?
    local branch
    branch=$(git_branch)

    # highlight return code error
    if (( last_exit )); then
        returncode="\[\e[1;31m\]" # red
    else
        returncode="\[\e[1;37m\]" # grey
    fi

    # highlight the user name when logged in as root
    if [[ "${USER}" == "root" ]]; then
        userstyle="\[\e[1;31m\]" # red
    else
        userstyle="\[\e[1;32m\]" # green
    fi

    # highlight the hostname when connected via SSH
    if [[ -n "${SSH_TTY}" \
              || -n "${SSH_CONNECTION}" \
              || -n "${SSH_CLIENT}" ]]
    then
        hoststyle="\[\e[1;33m\]" # yellow
    else
        hoststyle="\[\e[1;32m\]" # green
    fi

    PS1="${userstyle}\u"         # username
    PS1+="\[\e[1;37m\]@"         # @
    PS1+="${hoststyle}\h "       # hostname
    PS1+="\[\e[1;34m\]\w"        # working directory
    PS1+="\[\e[1;36m\]${branch}" # git details
    PS1+="${returncode} \$"      # $ with return code color
    PS1+="\[\e[0m\] "            # reset colors
}

PROMPT_COMMAND=set_prompt

for file in ~/.{aliases,exports}; do
    if [[ -r "${file}" && -f "${file}" ]]; then
        source "${file}"
    fi
done

unset file
