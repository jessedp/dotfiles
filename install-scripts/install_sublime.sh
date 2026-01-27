#!/bin/bash
# install-scripts/install_sublime.sh

echo "--- Installing Sublime Text ---"
if command -v subl &> /dev/null; then
    echo "SUCCESS: Sublime Text is already installed."
else
    echo "INFO: Sublime Text not found. Installing..."
    
    # Create a temporary directory for downloads
    TEMP_DIR=$(mktemp -d)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create a temporary directory."
        exit 1
    fi
    
    SUBLIME_DEB="${TEMP_DIR}/sublime-text.deb"
    
    echo "INFO: Downloading Sublime Text .deb package..."
    curl -L "https://download.sublimetext.com/sublime-text_build-4126_amd64.deb" -o "${SUBLIME_DEB}"
    
    if [ $? -eq 0 ]; then
        echo "INFO: Installing Sublime Text .deb package..."
        sudo apt update
        sudo dpkg -i "${SUBLIME_DEB}"
        
        # Fix potential dependency issues
        sudo apt install -f -y
        
        if [ $? -eq 0 ]; then
            echo "SUCCESS: Sublime Text installed."
        else
            echo "ERROR: Failed to install Sublime Text .deb package."
        fi
    else
        echo "ERROR: Failed to download Sublime Text .deb package."
    fi
    
    # Clean up the temporary directory
    rm -rf "${TEMP_DIR}"
fi
echo "--------------------------"
