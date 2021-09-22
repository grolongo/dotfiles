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

### Emacs vterm
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

### Prompt

prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a Git repository.
    if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

            if [[ -O "$(git rev-parse --show-toplevel)/.git/index" ]]; then
                git update-index --really-refresh -q &> /dev/null;
            fi;

            # Check for uncommitted changes in the index.
            if ! git diff --quiet --ignore-submodules --cached; then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! git diff-files --quiet --ignore-submodules --; then
                s+='!';
            fi;

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?';
            fi;

            # Check for stashed files.
            if git rev-parse --verify refs/stash &>/dev/null; then
                s+='$';
            fi;

        fi;

        # Get the short symbolic ref.
        # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
        # Otherwise, just give up.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || echo '(unknown)')";

        [ -n "${s}" ] && s="${s}";

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

PS1="\[\e[1;37m\][";                # [
PS1+="${userStyle}\u";              # username
PS1+="\[\e[1;37m\]@";               # @
PS1+="${hostStyle}\h ";             # hostname
PS1+="\[\e[1;34m\]\w";              # working dir
PS1+="\[\e[1;36m\]\$(prompt_git)";  # git repository details
PS1+="\[\e[1;37m\]]\$";             # ]$
PS1+="\[\e[0m\] ";                  # reset colors

export PS1;

### External

if [[ -r "$HOME/.aliases" ]] && [[ -f "$HOME/.aliases" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.aliases"
fi
