#!/bin/bash
#
# Scan a bed of cards, then crop/trim them into a self-contained run directory:
#
#   $CARD_SCANS_DIR/YYYYMMDD_runNNN/
#       YYYYMMDD_runNNN.jpg   original scan
#       cropped/              cropped + rotated cards
#       trimmed/              whitespace trimmed (renamed by player with -o)
#
# Any args (e.g. -o for OCR renaming) are passed through to process_cards.py.
# Scans are scratch work - the base dir is deliberately outside ~/Documents
# so it isn't synced or backed up. Delete old runs whenever.

# Set the base path
BASEPATH="${CARD_SCANS_DIR:-$HOME/card-scans}"
mkdir -p "$BASEPATH"

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

# Each run gets its own directory holding the original and all outputs
run_name=$(printf "${current_date}_run%03d" "$next_run")
run_dir="$BASEPATH/$run_name"
output_file="$run_dir/$run_name.jpg"

# Function to handle cleanup on interrupt
cleanup() {
    if [ -d "$run_dir" ]; then
        echo "Cleaning up interrupted scan..."
        rm -rf "$run_dir"
        # Roll back the run number if we didn't complete the scan
        echo "$current_run" > "$RUNS_FILE"
    fi
    exit 1
}

# Function to show desktop notification
notify_completion() {
    if [ -x "$(command -v notify-send)" ]; then
        notify-send -i scanner "Scan Complete" "Saved scan as $run_name.jpg\nin $run_dir"
    else
        echo "notify-send not found. Install libnotify-bin for desktop notifications."
    fi
}

split_image() {
    cd ~/projects/python/card-tools/ || return 1
    uv run process_cards.py "$@" --out "$run_dir" "$output_file"
}

# Trap Ctrl+C and other interrupts
trap cleanup INT TERM

# Update the .runs file first (before scanning)
echo "$next_run" > "$RUNS_FILE"
mkdir -p "$run_dir"

# Execute the scan command
if scanimage --progress --format=jpeg --mode Color --resolution 300 --output-file="$output_file"; then
    # Scan is complete - don't delete it if processing gets interrupted
    trap - INT TERM
    echo "$output_file"
    notify_completion
    split_image "$@"
else
    # If scan failed, clean up and restore previous run number
    cleanup
fi
