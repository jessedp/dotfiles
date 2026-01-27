#!/bin/bash
# install-scripts/install_vscode.sh

echo "--- Installing VSCode ---"
if command -v code &> /dev/null; then
    echo "SUCCESS: VSCode is already installed."
else
    echo "INFO: VSCode not found. Installing..."
    
    # Create a temporary directory for downloads
    TEMP_DIR=$(mktemp -d)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create a temporary directory."
        exit 1
    fi
    
    VSCODE_DEB="${TEMP_DIR}/vscode.deb"
    
    echo "INFO: Downloading VSCode .deb package..."
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o "${VSCODE_DEB}"
    
    if [ $? -eq 0 ]; then
        echo "INFO: Installing VSCode .deb package..."
        sudo apt update
        sudo dpkg -i "${VSCODE_DEB}"
        
        # Fix potential dependency issues
        sudo apt install -f -y
        
        if [ $? -eq 0 ]; then
            echo "SUCCESS: VSCode installed."
        else
            echo "ERROR: Failed to install VSCode .deb package."
        fi
    else
        echo "ERROR: Failed to download VSCode .deb package."
    fi
    
    # Clean up the temporary directory
    rm -rf "${TEMP_DIR}"
fi
echo "--------------------------"
