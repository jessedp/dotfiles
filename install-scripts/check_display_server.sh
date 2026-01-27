#!/bin/bash
# install-scripts/check_display_server.sh

echo "--- Checking for display server ---"
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo "SUCCESS: Display server (X11 or Wayland) detected."
else
    echo "INFO: No display server detected. GUI applications may not install or work."
fi
echo "-----------------------------------"
