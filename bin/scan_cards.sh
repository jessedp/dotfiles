#!/bin/bash

# Set the base path
BASEPATH="$HOME/Documents/cards/scans"

# Ensure the done directory exists
mkdir -p "$BASEPATH/done"

# Read and increment the run number
RUNS_FILE="$BASEPATH/.runs"

# Initialize run number to 0 if file doesn't exist
if [ ! -f "$RUNS_FILE" ]; then
    echo "0" > "$RUNS_FILE"
fi

# Read current run number
current_run=$(cat "$RUNS_FILE")

# Increment the run number
next_run=$((current_run + 1))

# Get current date in YYYYMMDD format
current_date=$(date +"%Y%m%d")

# Format the filename with date prefix and leading zeros
filename=$(printf "${current_date}_run%03d.jpg" "$next_run")
output_file="$BASEPATH/$filename"

# Function to handle cleanup on interrupt
cleanup() {
    if [ -f "$output_file" ]; then
        echo "Cleaning up interrupted scan..."
        rm -f "$output_file"
        # Roll back the run number if we didn't complete the scan
        echo "$current_run" > "$RUNS_FILE"
    fi
    exit 1
}

# Function to show desktop notification
notify_completion() {
    if [ -x "$(command -v notify-send)" ]; then
        notify-send -i scanner "Scan Complete" "Saved scan as $filename\nin $BASEPATH"
    else
        echo "notify-send not found. Install libnotify-bin for desktop notifications."
    fi
}

# Trap Ctrl+C and other interrupts
trap cleanup INT TERM

# Update the .runs file first (before scanning)
echo "$next_run" > "$RUNS_FILE"

# Execute the scan command
if scanimage --progress --format=jpeg --mode Color --resolution 300 --output-file="$output_file"; then
    echo "Scan successfully saved as $BASEPATH/$filename"
    xdg-open "$BASEPATH/$filename"
    notify_completion
else
    # If scan failed, clean up and restore previous run number
    cleanup
fi
