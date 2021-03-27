# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Read bash aliases and functions
[[ -f ~/.bash_functions ]] && . ~/.bash_functions
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Add user bin and /usr/local to beginning of path
prepend PATH /usr/local/sbin:/usr/local/bin
prepend PATH $HOME/bin
export PATH


# Done unless this is an interactive shell
[ -z "$PS1" ] && return

# Load additional bash init files
_load_bashrc_d

# make sure...
export PATH

# # Powerline
# PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
# source /home/jesse/.local/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh


# source /home/jesse/.config/broot/launcher/bash/br
