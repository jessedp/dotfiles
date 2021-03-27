# ORIGINAL UBUNTU PROMPT

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] __git_ps1\$ "

export GIT_PS1_SHOWCOLORHINTS=true # Option for git-prompt.sh to show branch name in color

# Terminal Prompt:
# Include git branch, use PROMPT_COMMAND (not PS1) to get color output (see git-prompt.sh for more)
# export PROMPT_COMMAND='__git_ps1 "\w" "\n\\\$ "' # Git branch (relies on git-prompt.sh)
export GIT_PS1_SHOWDIRTYSTATE=1
# export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
# export GIT_PS1_SHOWUPSTREAM="auto"
# export PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "' # Git branch (relies on git-prompt.sh)   ⎇

# export PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]" "\\\$ "  " ⎇  %s "' # Git branch (relies on git-prompt.sh)

# export PROMPT_COMMAND=

# _ps1_symbol='\[\e[38;2;0;255;0;48;2;70;70;70m\] \$ \[\e[0m\]\[\e[38;2;70;70;70m\]\[\e[0m\]'
# export PS1='\[\e]0;\w\a\]\[\e[38;2;40;40;40;48;2;153;204;255m\] \u\[\e[38;2;255;57;57;48;2;153;204;255m\]@\[\e[0m\]\[\e[38;2;40;40;40;48;2;153;204;255m\]\h \[\e[0m\]\[\e[38;2;153;204;255;48;2;255;150;50m\]\[\e[0m\]\[\e[38;2;40;40;40;48;2;255;150;50m\] \W \[\e[0m\]\[\e[38;2;255;150;50;48;2;70;70;70m\]\[\e[0m\]$(__git_ps1 "\[\e[38;2;0;255;0;48;2;70;70;70m\] %s \[\e[0m\]\[\e[38;2;0;0;0;48;2;70;70;70m\] \[\e[0m\]")'"${_ps1_symbol}"' '
# export PS1='\[\e]0;\w\a\]\[\e[38;2;40;40;40;48;2;153;204;255m\] \u@\h \[\e[0m\]\[\e[38;2;153;204;255;48;2;255;150;50m\]\[\e[0m\]\[\e[38;2;40;40;40;48;2;255;150;50m\] \W \[\e[0m\]\[\e[38;2;255;150;50;48;2;70;70;70m\]\[\e[0m\]$(__git_ps1 "\[\e[38;2;0;255;0;48;2;70;70;70m\] %s \[\e[0m\]\[\e[38;2;0;0;0;48;2;70;70;70m\] \[\e[0m\]")'"${_ps1_symbol}"' '
# unset _ps1_symbol


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
