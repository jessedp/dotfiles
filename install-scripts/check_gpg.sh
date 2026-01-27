#!/bin/bash
# install-scripts/check_gpg.sh

echo "--- Checking GPG configuration for Git signing ---"
GPG_SIGNING_KEY=$(git config user.signingkey)

if [ -n "$GPG_SIGNING_KEY" ]; then
    echo "INFO: Git user.signingkey is set to: $GPG_SIGNING_KEY"
    if gpg --list-secret-keys --keyid-format LONG "$GPG_SIGNING_KEY" &> /dev/null; then
        echo "SUCCESS: GPG secret key '$GPG_SIGNING_KEY' found in keyring."
    else
        echo "WARNING: GPG secret key '$GPG_SIGNING_KEY' not found in keyring."
        echo "    Ensure the key exists and is imported (gpg --import)."
        echo "    You might need to generate a new key if you don't have one."
    fi
else
    # Check if any secret keys exist, even if user.signingkey is not explicitly set
    if gpg --list-secret-keys --keyid-format LONG &> /dev/null; then
        echo "INFO: Git user.signingkey is not explicitly set, but GPG secret keys exist."
        echo "    You may need to configure 'git config --global user.signingkey <KEY_ID>'."
        echo "    To list available keys: gpg --list-secret-keys --keyid-format LONG"
    else
        echo "WARNING: No GPG secret key configured for Git signing and no keys found in keyring."
        echo "    You have 'commit.gpgsign = true' in your .gitconfig, but no key to sign with."
        echo "    To generate a GPG key: gpg --full-generate-key"
        echo "    Then configure Git to use it: git config --global user.signingkey <KEY_ID>"
    fi
fi
echo "--------------------------------------------------"
