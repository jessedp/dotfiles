#!/bin/bash

# Check if hostname is provided
if [ -z "$1" ]; then
    echo "Usage: ./check_node.sh <hostname_or_ip>"
    exit 1
fi

TARGET_HOST=$1

ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 -t "$TARGET_HOST" << 'EOF'
    echo "--- $(hostname) ---"
    
    # CPU: Grab first 'model name' or 'Hardware' (for ARM/Pis)
    CPU=$(grep -E -m1 'model name|Hardware' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
    echo "CPU: $CPU"
    
    # RAM: Standard free -h
    echo "RAM:"
    free -h | awk '/^Mem:/ {print "  Total: " $2 " | Used: " $3 " | Free: " $4}'
    
    # Disk: Filter out virtual/temp filesystems but keep / and NFS
    echo "Disk (Physical & NFS):"
    df -h | grep -vE 'tmpfs|devtmpfs|loop|udev|shm|run' | awk 'NR==1 || /^\// || /:/ {printf "  %-20s %-10s %-10s %s\n", $1, $2, $3, $6}'
EOF
