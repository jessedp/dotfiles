#!/bin/bash
# install-scripts/install_lazygit.sh

echo "--- Installing Lazygit ---"
if command -v lazygit &> /dev/null; then
    echo "SUCCESS: Lazygit is already installed."
else
    echo "INFO: Lazygit not found. Installing..."

    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')

    if [ -z "$LAZYGIT_VERSION" ]; then
        echo "ERROR: Could not fetch latest Lazygit version."
        exit 1
    fi

    echo "INFO: Downloading Lazygit v${LAZYGIT_VERSION}..."
    TEMP_DIR=$(mktemp -d)
    curl -Lo "${TEMP_DIR}/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

    if [ $? -eq 0 ]; then
        echo "INFO: Extracting and installing Lazygit..."
        tar xf "${TEMP_DIR}/lazygit.tar.gz" -C "${TEMP_DIR}" lazygit
        sudo install "${TEMP_DIR}/lazygit" /usr/local/bin/
        if [ $? -eq 0 ]; then
            echo "SUCCESS: Lazygit installed."
        else
            echo "ERROR: Failed to install Lazygit."
        fi
    else
        echo "ERROR: Failed to download Lazygit."
    fi
    
    rm -rf "${TEMP_DIR}"
fi
echo "--------------------------"
