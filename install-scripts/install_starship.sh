#!/bin/bash
# install-scripts/install_starship.sh

echo "--- Installing Starship prompt ---"
if command -v starship &> /dev/null; then
    echo "SUCCESS: Starship is already installed."
else
    echo "INFO: Starship not found. Installing..."
    curl -sS https://starship.rs/install.sh | sh
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Starship installed."
    else
        echo "ERROR: Failed to install Starship."
    fi
fi
echo "----------------------------------"
