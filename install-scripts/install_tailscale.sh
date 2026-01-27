#!/bin/bash
# install-scripts/install_tailscale.sh

echo "--- Installing Tailscale ---"
if command -v tailscale &> /dev/null; then
    echo "SUCCESS: Tailscale is already installed."
else
    echo "INFO: Tailscale not found. Installing..."
    curl -fsSL https://tailscale.com/install.sh | sh
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Tailscale installed."
    else
        echo "ERROR: Failed to install Tailscale."
    fi
fi
echo "--------------------------"
