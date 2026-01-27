#!/bin/bash
# install-scripts/check_ssh.sh

echo "--- Checking SSH key setup ---"
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "SUCCESS: SSH key ~/.ssh/id_ed25519 already exists."
else
    echo "INFO: SSH key not found. Generating a new one."
    # Ensure .ssh directory exists
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    # Generate key non-interactively
    ssh-keygen -t ed25519 -C "jesse@new-laptop-2026" -f ~/.ssh/id_ed25519 -N ""
    echo "SUCCESS: New SSH key generated."
fi

echo ""
echo "--- Your public SSH key is: ---"
cat ~/.ssh/id_ed25519.pub
echo "--------------------------------"
