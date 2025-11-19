#!/bin/bash
# Install a user system service:
#
# /home/jesse/.config/systemd/user/live_mirror.service 
#
# [Unit]
# Description=Live mirror from source to destination with 4-week cleanup
# After=default.target
#
# [Service]
# ExecStartPre=/usr/bin/test -d %h/PixelCamera/Camera
# ExecStart=%h/bin/live_mirror_cleanup.sh
# Restart=always
# RestartSec=5
#
# [Install]
# WantedBy=default.target

# Change these directories: 

SRC_DIR="$HOME/PixelCamera/Camera"
DST_DIR="$HOME/Pictures/Pixel7"

mkdir -p "$DST_DIR"

# Initial sync (only new/changed files from last 28 days)
# Find files, pipe to rsync, and then run halfimg.sh on the transferred files.
find "$SRC_DIR" -type f -mtime -28 -not -name '*.tmp' -printf '%P\0' | \
rsync -a --update --files-from=- --from0 "$SRC_DIR/" "$DST_DIR/" --out-format='%n' | \
while read -r rel_file_path; do
    if [ -n "$rel_file_path" ]; then
        /home/jesse/bin/halfimg.sh "$DST_DIR/$rel_file_path"
    fi
done

# Start watcher
inotifywait -m -r -e create,modify,move --format '%w%f' "$SRC_DIR" | while read -r file; do
    if [[ "$file" == *.tmp ]]; then
        continue
    fi
    # If it's a file, copy just that file
    if [ -f "$file" ]; then
        relpath="${file#$SRC_DIR/}"
        dst_path="$DST_DIR/$relpath"
        mkdir -p "$(dirname "$dst_path")"
        if rsync -a --update --itemize-changes "$file" "$dst_path" | grep -q '^>f'; then
            /home/jesse/bin/halfimg.sh "$dst_path"
        fi
    fi
done &
watcher_pid=$!

# Run cleanup every 6 hours without triggering watcher
while true; do
    find "$DST_DIR" -type f -mtime +28 -delete
    sleep 6h
done
