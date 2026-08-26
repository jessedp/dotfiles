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

alias dump_session='journalctl -b -0 > logs.txt'
alias actvenv='source venv/bin/activate'

alias ffpm='firefox -ProfileManager'

# >>> herdr oomd-exempt wrapper (2026-08-26) >>>
# herdr spawns its server into the launching terminal's cgroup; systemd-oomd killed
# that tab (and every agent in it) on 2026-08-18/25. Launch-style calls run inside a
# transient scope oomd will not select; other subcommands pass straight through.
herdr() {
  local bin; bin=$(type -P herdr) || bin="$HOME/.local/bin/herdr"
  case "${1-}" in
    ''|--session|--remote|--handoff|--remote-keybindings|session)
      if systemctl --user show-environment >/dev/null 2>&1; then
        systemd-run --user --scope -q -p ManagedOOMPreference=omit \
          --description="herdr (oomd-exempt)" "$bin" "$@"
        return
      fi ;;
  esac
  "$bin" "$@"
}
# <<< herdr wrapper <<<
