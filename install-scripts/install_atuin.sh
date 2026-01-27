#!/bin/bash
# install-scripts/install_atuin.sh

echo "--- Installing Atuin ---"
if command -v atuin &> /dev/null; then
    echo "SUCCESS: Atuin is already installed."
else
    echo "INFO: Atuin not found. Installing..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Atuin installed."
    else
        echo "ERROR: Failed to install Atuin."
    fi
fi
echo "--------------------------"
