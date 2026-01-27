#!/bin/bash
# install-scripts/install_nvm.sh

echo "--- Installing nvm (Node Version Manager) ---"
# Check if nvm is already installed by sourcing it and checking command existence
NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    if command -v nvm &> /dev/null; then
        echo "SUCCESS: nvm is already installed."
    fi
fi

if ! command -v nvm &> /dev/null; then
    echo "INFO: nvm not found. Installing..."

    # Get the latest nvm version from GitHub API
    NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    
    if [ -z "$NVM_VERSION" ]; then
        echo "ERROR: Could not fetch latest nvm version. Using fallback v0.39.3"
        NVM_VERSION="0.39.3" # Fallback version
    fi

    echo "INFO: Installing nvm version v${NVM_VERSION}..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
    
    if [ $? -eq 0 ]; then
        echo "SUCCESS: nvm installed. Please restart your shell or source ~/.bashrc (or equivalent) for nvm to be available."
        # Source nvm for immediate use in this script
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi
    else
        echo "ERROR: Failed to install nvm."
    fi
fi

# Install LTS node version if nvm is available
if command -v nvm &> /dev/null; then
    echo "INFO: Installing latest LTS Node.js version..."
    nvm install --lts
    if [ $? -eq 0 ]; then
        echo "SUCCESS: LTS Node.js installed and set as default."
        nvm use --lts
    else
        echo "ERROR: Failed to install LTS Node.js."
    fi
fi
echo "-------------------------------------------"
