# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

### History
shopt -s histappend
HISTFILE=~/.cache/bash/history
HISTCONTROL=ignoreboth
HISTSIZE=9999
HISTFILESIZE=9999
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

### Prompt

function git_branch_name()
{
    # Check if the current directory is in a Git repository.
    if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

        [ -n "${s}" ] && s=" [${s}]";

        echo -e " ${1}${branchName}${s}";
    else
	return;
    fi;
}

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
    userStyle="\[\e[1;31m\]"; # red
else
    userStyle="\[\e[1;32m\]"; # green
fi;

# Highlight the hostname when connected via SSH.
if [ -n "${SSH_TTY}" ] || \
       [ -n "${SSH_CONNECTION}" ] || \
       [ -n "${SSH_CLIENT}" ]; then
    hostStyle="\[\e[1;33m\]";       # yellow
else
    hostStyle="\[\e[1;30m\]";       # grey
fi;

PS1="\[\e[1;37m\][";                    # [
PS1+="${userStyle}\u";                  # username
PS1+="\[\e[1;37m\]@";                   # @
PS1+="${hostStyle}\h ";                 # hostname
PS1+="\[\e[1;34m\]\w";                  # working dir
PS1+="\[\e[1;36m\]\$(git_branch_name)"; # git repository details
PS1+="\[\e[1;37m\]]\$";                 # ]$
PS1+="\[\e[0m\] ";                      # reset colors

export PS1;

### External

for file in ~/.{aliases,exports}; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
	    source "$file"
    fi
done
unset file

