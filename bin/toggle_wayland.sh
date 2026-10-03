#!/bin/bash
CONF="/etc/gdm3/custom.conf"
if grep -q "^WaylandEnable=false" "$CONF"; then
    echo "Enabling Wayland..."
    sudo sed -i 's/^WaylandEnable=false/#WaylandEnable=false/' "$CONF"
else
    echo "Disabling Wayland (Switching to Xorg)..."
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' "$CONF"
fi
echo "Restarting GDM... (This will log you out!)"
sudo systemctl restart gdm3
