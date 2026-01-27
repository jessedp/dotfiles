#!/bin/bash
# install-scripts/install_dbeaver.sh

echo "--- Installing Dbeaver ---"
if command -v snap &> /dev/null; then
    if snap list | grep dbeaver-ce &> /dev/null; then
        echo "SUCCESS: Dbeaver is already installed via Snap."
    else
        echo "INFO: Dbeaver not found. Installing via Snap..."
        sudo snap install dbeaver-ce --classic
        if [ $? -eq 0 ]; then
            echo "SUCCESS: Dbeaver installed."
        else
            echo "ERROR: Failed to install Dbeaver via Snap."
        fi
    fi
else
    echo "WARNING: Snap is not installed. Cannot install Dbeaver via Snap."
    echo "    To install snap: sudo apt update && sudo apt install snapd"
fi
echo "--------------------------"
