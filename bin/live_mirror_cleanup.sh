#!/bin/bash
SRC_DIR="$HOME/PixelCamera/Camera"
DST_DIR="$HOME/Pictures/Pixel7"

mkdir -p "$DST_DIR"

# Initial sync (only new/changed files)
# rsync -a --update "$SRC_DIR"/ "$DST_DIR"/
find "$SRC_DIR" -type f -mtime -28 -print0 | xargs -I '{}' -0 cp -a '{}' "$DST_DIR"

# Start watcher
inotifywait -m -r -e create,modify,move --format '%w%f' "$SRC_DIR" | while read -r file; do
    # If it's a file, copy just that file
    if [ -f "$file" ]; then
        relpath="${file#$SRC_DIR/}"
        mkdir -p "$DST_DIR/$(dirname "$relpath")"
        rsync -a --update "$file" "$DST_DIR/$relpath"
    fi
done &
watcher_pid=$!

# Run cleanup every 6 hours without triggering watcher
while true; do
    find "$DST_DIR" -type f -mtime +28 -delete
    sleep 6h
done
