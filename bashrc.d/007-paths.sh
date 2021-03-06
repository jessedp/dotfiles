export GOPATH=$HOME/go
export GOROOT=/usr/lib/go-1.10
append PATH $GOROOT/bin:$GOPATH/bin
#append $GOROOT

append PATH $HOME/.config/composer/vendor/bin
append PATH $HOME/.local/bin

# RUST bins
if [ -d $HOME/.cargo/bin ]; then
    export PATH=$PATH:$HOME/.cargo/bin
fi
