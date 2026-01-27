#!/bin/bash
set -euo pipefail

# Define the patterns to check
patterns=(
    "$HOME/.bashrc.d/*.sh"
    "rclone-wrapper/*.sh"
    "install-scripts/*.sh"
)

failed=0

# Iterate through patterns
for pattern in "${patterns[@]}"; do
    # Expand the glob pattern
    # We use 'compgen -G' or simple expansion. Since these might be relative or absolute,
    # and we want to handle the case where a pattern matches nothing gracefully.
    
    # Simple expansion with nullglob to handle no matches
    shopt -s nullglob
    files=($pattern)
    shopt -u nullglob

    for file in "${files[@]}"; do
        if [[ -f "$file" && ! -x "$file" ]]; then
            echo "❌ ERROR: File is not executable: $file"
            failed=1
        fi
    done
done

if [ "$failed" -eq 1 ]; then
    echo "Some scripts are not executable. Please fix permissions manually using 'chmod +x <file>'."
    exit 1
else
    echo "✅ All scripts are executable."
    exit 0
fi
