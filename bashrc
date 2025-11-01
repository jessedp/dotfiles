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

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"


# Setup NVM stuff
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME/.cargo/env"

#cdnvm() {
#    command cd "$@";
#    nvm_path=$(nvm_find_up .nvmrc | tr -d '\n')
#
#    # If there are no .nvmrc file, use the default nvm version
#    if [[ ! $nvm_path = *[^[:space:]]* ]]; then
#
#        declare default_version;
#        default_version=$(nvm version default);
#
#        # If there is no default version, set it to `node`
#        # This will use the latest version on your machine
#        if [[ $default_version == "N/A" ]]; then
#            nvm alias default node;
#            default_version=$(nvm version default);
#        fi
#
#        # If the current version is not the default version, set it to use the default version
#        if [[ $(nvm current) != "$default_version" ]]; then
#            nvm use default;
#        fi
#
#    elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
#        declare nvm_version
#        nvm_version=$(<"$nvm_path"/.nvmrc)
#
#        declare locally_resolved_nvm_version
#        # `nvm ls` will check all locally-available versions
#        # If there are multiple matching versions, take the latest one
#        # Remove the `->` and `*` characters and spaces
#        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
#        locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')
#
#        # If it is not already installed, install it
#        # `nvm install` will implicitly use the newly-installed version
#        if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
#            nvm install "$nvm_version";
#        elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
#            nvm use "$nvm_version";
#        fi
#    fi
#}
#alias cd='cdnvm'
#cd "$PWD"
#

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

. "$HOME/.atuin/bin/env"

