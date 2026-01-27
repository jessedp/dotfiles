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

# Check for display server before installing GUI packages
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo "INFO: Display server detected. Installing common GUI packages..."
    sudo apt-get install -y gparted
    echo "INFO: Display server detected. Installing my GUI packages..."
    sudo apt-get install -y meld rpi-imager flameshot gnome-tweaks
else
    echo "INFO: No display server detected. Skipping GUI package installation."
fi

echo "-------------------------------"
