#!/bin/bash
# install-scripts/install_apt_packages.sh

echo "--- Installing APT packages ---"

# Check if running on Ubuntu
if [ "$(lsb_release -is)" != "Ubuntu" ]; then
    echo "INFO: Not running on Ubuntu. Skipping APT package installation."
    exit 0
fi

echo "INFO: Updating package repos..."
sudo apt-get update

echo "INFO: Installing common CLI packages..."
sudo apt-get install -y build-essential git sqlite3 curl vim tmux zsh python3-pip tree nfs-common htop

echo "INFO: Installing my CLI packages..."
sudo apt-get install -y jq rclone mc qrencode shellcheck traceroute mtr iftop syncthing

# Check for "desktop" profile before installing GUI packages
if [ "$DOTFILES_PROFILE" == "desktop" ]; then
    echo "INFO: 'desktop' profile detected. Installing common GUI packages..."
    sudo apt-get install -y gparted
    echo "INFO: 'desktop' profile detected. Installing my GUI packages..."
    sudo apt-get install -y meld rpi-imager flameshot gnome-tweaks
else
    echo "INFO: 'desktop' profile not detected. Skipping GUI package installation."
fi

echo "-------------------------------"
