#!/bin/bash
#
# Level and frame phone photos of single cards (case and all) to 3:4 with an
# even margin, into a self-contained run directory like scan_cards.sh does:
#
#   $CARD_SCANS_DIR/YYYYMMDD_runNNN/
#       <original photos>
#       framed/     leveled + cropped to 3:4 (colors untouched)
#       cleaned/    with --clean: also white balanced, gentle levels
#       debug/      each photo with the detected object and frame
#
# Usage:
#   photo_cards.sh [--clean]            process (and empty) $CARD_SCANS_DIR/inbox
#   photo_cards.sh [--clean] FILE...    process these files (copied, not moved)
#
# Photos it isn't sure about aren't framed - see debug/ and do those by hand.

BASEPATH="${CARD_SCANS_DIR:-$HOME/card-scans}"
INBOX="$BASEPATH/inbox"
mkdir -p "$INBOX"

options=()
files=()
for arg in "$@"; do
    case "$arg" in
        --*) options+=("$arg") ;;
        *) files+=("$arg") ;;
    esac
done

from_inbox=false
if [ ${#files[@]} -eq 0 ]; then
    from_inbox=true
    shopt -s nullglob nocaseglob
    files=("$INBOX"/*.{jpg,jpeg,png,webp})
    shopt -u nullglob nocaseglob
fi
if [ ${#files[@]} -eq 0 ]; then
    echo "No photos given and nothing in $INBOX"
    exit 1
fi

# Same run counter as scan_cards.sh
RUNS_FILE="$BASEPATH/.runs"
[ -f "$RUNS_FILE" ] || echo "0" > "$RUNS_FILE"
next_run=$(( $(cat "$RUNS_FILE") + 1 ))
echo "$next_run" > "$RUNS_FILE"
run_dir="$BASEPATH/$(printf "%s_run%03d" "$(date +%Y%m%d)" "$next_run")"
mkdir -p "$run_dir"

# Originals live in the run dir; inbox photos are moved there, others copied
photos=()
for f in "${files[@]}"; do
    if $from_inbox; then
        mv "$f" "$run_dir/"
    else
        cp "$f" "$run_dir/"
    fi
    photos+=("$run_dir/$(basename "$f")")
done

cd ~/projects/python/card-tools/ || exit 1
uv run process_photos.py "${options[@]}" --out "$run_dir" "${photos[@]}"
xdg-open "$run_dir" >/dev/null 2>&1 &
