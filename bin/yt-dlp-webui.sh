#!/usr/bin/env bash

# Determine if the wireproxy VPN SOCKS5 proxy is active on port 25344
if command -v ss >/dev/null 2>&1; then
    VPN_ACTIVE=$(ss -tuln | grep -q ":25344 " && echo "yes" || echo "no")
elif command -v netstat >/dev/null 2>&1; then
    VPN_ACTIVE=$(netstat -tuln | grep -q ":25344 " && echo "yes" || echo "no")
else
    # Fallback to python check
    VPN_ACTIVE=$(python3 -c 'import socket; s = socket.socket(); s.settimeout(0.5); print("yes" if s.connect_ex(("127.0.0.1", 25344)) == 0 else "no")')
fi

if [ "$VPN_ACTIVE" = "yes" ]; then
    echo "=========================================================="
    echo "VPN detected (wireproxy active on port 25344)."
    echo "Starting yt-dlp-webui ROUTED THROUGH THE VPN..."
    echo "=========================================================="
    
    # Remove any existing containers on port 3033 or named yt-dlp-webui to prevent conflicts
    CONFLICTING_CONTAINERS=$(docker ps -aq --filter publish=3033)
    if [ -n "$CONFLICTING_CONTAINERS" ]; then
        echo "Removing conflicting container(s) using port 3033..."
        docker rm -f $CONFLICTING_CONTAINERS || true
    fi
    docker rm -f yt-dlp-webui 2>/dev/null || true
    
    docker run -d \
      --name yt-dlp-webui \
      -p 3033:3033 \
      -v /mnt/Private/ytdlp/:/downloads \
      -v /home/jesse/projects/wireproxy/cookies.txt:/cookies.txt \
      -v /home/jesse/projects/wireproxy/yt-dlp.conf:/etc/yt-dlp.conf:ro \
      --add-host=host.docker.internal:host-gateway \
      -e ALL_PROXY="socks5h://host.docker.internal:25344" \
      -e all_proxy="socks5h://host.docker.internal:25344" \
      -e HTTP_PROXY="socks5h://host.docker.internal:25344" \
      -e HTTPS_PROXY="socks5h://host.docker.internal:25344" \
      marcobaobao/yt-dlp-webui --qs 8
else
    echo "=========================================================="
    echo "WARNING: VPN (wireproxy on port 25344) is NOT running."
    echo "=========================================================="
    echo "Choose one of the following options:"
    echo "  1) Start direct (NO VPN)"
    echo "  2) Abort and start wireproxy first"
    echo "=========================================================="
    read -rp "Enter choice [1-2]: " choice
    case "$choice" in
        1)
            echo "Starting yt-dlp-webui DIRECTLY (NO VPN)..."
            CONFLICTING_CONTAINERS=$(docker ps -aq --filter publish=3033)
            if [ -n "$CONFLICTING_CONTAINERS" ]; then
                echo "Removing conflicting container(s) using port 3033..."
                docker rm -f $CONFLICTING_CONTAINERS || true
            fi
            docker rm -f yt-dlp-webui 2>/dev/null || true
            docker run -d \
              --name yt-dlp-webui \
              -p 3033:3033 \
              -v /mnt/Private/ytdlp/:/downloads \
              -v /home/jesse/projects/wireproxy/cookies.txt:/cookies.txt \
              -v /home/jesse/projects/wireproxy/yt-dlp.conf:/etc/yt-dlp.conf:ro \
              marcobaobao/yt-dlp-webui --qs 8
            ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
fi
