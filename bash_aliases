# some more ls aliases
alias ll='ls -alFhrt'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# serve jekyll from cur dir
alias jk='bundle exec jekyll serve --trace'
alias hs='python -m http.server 8000'

# sure.
alias git-summary='/home/jesse/projects/git-summary/git-summary  -d ~/projects/'


# $1 is a command, grabs/displays common usage tips
function cheat() {
      curl cht.sh/$1
}

# open firefox with a blank profile
alias fx='firefox --new-instance --profile $(mktemp -d)'
