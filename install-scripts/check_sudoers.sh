#!/bin/bash
# install-scripts/check_sudoers.sh

echo "--- Checking sudoers setup ---"
if sudo -n true 2>/dev/null; then
    echo "SUCCESS: User has passwordless sudo."
else
    echo "WARNING: This script will ask for your password for 'sudo' commands."
    echo "    To avoid this, consider adding a sudoers rule for your user, for example:"
    echo "    $USER ALL=(ALL) NOPASSWD: ALL"
fi
echo "------------------------------"
