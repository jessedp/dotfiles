# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# extract almost anything
function extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export GOPATH=$HOME/go
export GOROOT=/usr/lib/go-1.10
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$HOME/.config/composer/vendor/bin:/home/jesse/.local/bin:$GOROOT

# RUST bins
if [ -d $HOME/.cargo/bin ]; then
    export PATH=$PATH:$HOME/.cargo/bin
fi

# alias python=python3
alias git-summary='/home/jesse/projects/git-summary/git-summary  -d ~/projects/'
# keeps history in sync across terminals
#export PROMPT_COMMAND="history -a; history -n"

# psgrep
psgrep() { 
    ps up $(pgrep -f $@) 2>&-; 
}

# json pretty print
prettyjson_s() {
    echo "$1" | python -m json.tool
}

prettyjson_f() {
    python -m json.tool "$1"
}

prettyjson_w() {
    curl "$1" | python -m json.tool
}

# Get your router's MAC address
find_rtr_mac() {
  local GWIP=$(route -n | grep "^0.0" | cut -c 17-32)
  local RTR_MAC=$(arp -n $GWIP | grep "$GWIP" | cut -c 34-50)
}

# ssh wrapper to allow "dynamic" host config
ssh() {
  HOME_MAC="58:ef:68:ab:62:6a"
  
  RTR_MAC=$(find_rtr_mac)
  HOME_MAC=${HOME_MAC//:}
  RTR_MAC=${RTR_MAC//:}
  if [ "${RTR_MAC^^}" == "${HOME_MAC^^}" ]; then
    echo "Host oscar
  Hostname 192.168.1.5
  User jesse
" > ~/.ssh/roaming
  else
    echo "Host oscar
  Hostname home.thebaconoflife.com
  User jesse
  Port 22378
" > ~/.ssh/roaming
  fi
  /usr/bin/ssh "$@"
}

# use bc to do maths
calc() { bc -l <<< "$1"; }

# go to something in log dir
gl () { cd /var/log/"$@"; }

#python
#(~/lastseen --daemon)

#go
# /home/jesse/go/bin/lastseen-go -daemon start

# added by travis gem
#[ -f /home/jesse/.travis/travis.sh ] && source /home/jesse/.travis/travis.sh

# Powerline
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
source /home/jesse/.local/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh


source /home/jesse/.config/broot/launcher/bash/br
