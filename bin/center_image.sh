#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick (convert) is not installed. Please install it first."
    exit 1
fi

# Default: white background
background="white"
auto_bg=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --auto-bg)
            auto_bg=true
            shift
            ;;
        *)
            input_image="$1"
            shift
            ;;
    esac
done

if [ -z "$input_image" ]; then
    echo "Usage: $0 [--auto-bg] <input_image>"
    exit 1
fi

# Detect edge color if --auto-bg is set
if [ "$auto_bg" = true ]; then
    background=$(convert "$input_image" -bordercolor none -border 1x1 -trim \
        -format "%[pixel:u.p{0,0}]\n" info:)
fi

# Base filename without extension
base_name="${input_image%.*}"

# Output files:
output_jpg="${base_name}_centered.jpg"
output_png="${base_name}_centered_transparent.png"

# Process JPEG (with specified background)
convert "$input_image" \
    -resize "700x700>" \
    -gravity center \
    -background "$background" \
    -extent 700x700 \
    "$output_jpg"

# Process PNG (transparent background)
convert "$input_image" \
    -resize "700x700>" \
    -gravity center \
    -background "none" \
    -extent 700x700 \
    "$output_png"

echo "Generated:"
echo "- JPEG (with background): $output_jpg"
echo "- PNG (transparent): $output_png"