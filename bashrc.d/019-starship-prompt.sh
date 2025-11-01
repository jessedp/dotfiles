eval "$(starship init bash)"
# Get the status code from the last command executed
STATUS=$?

# Get the number of jobs running.
NUM_JOBS=$(jobs -p | wc -l)

# Set the prompt to the output of `starship prompt`
PS1="$(starship prompt --status=$STATUS --jobs=$NUM_JOBS)"
set_win_title() {
    echo -ne "\033]0;${USER}@${HOSTNAME}:${PWD}\007"
}
precmd_functions+=(set_win_title)
