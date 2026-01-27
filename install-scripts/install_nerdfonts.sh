#!/bin/bash
# install-scripts/install_nerdfonts.sh

echo "--- Installing Nerd Fonts ---"
NERD_FONT_VERSION="3.2.1" # Latest version as of current knowledge
FONTS_DIR="$HOME/.local/share/fonts"
TEMP_DIR=$(mktemp -d)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create a temporary directory."
    exit 1
fi

mkdir -p "${FONTS_DIR}"

install_font() {
    local font_name=$1
    local zip_file="${font_name}.zip"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/${font_name}.zip"

    local font_target_dir="${FONTS_DIR}/${font_name}"

    if [ -d "${font_target_dir}" ] && [ "$(ls -A "${font_target_dir}"/*.ttf 2>/dev/null | wc -l)" -gt 0 ]; then
        echo "SUCCESS: ${font_name} Nerd Font already exists. Skipping installation."
        return 0
    fi

    echo "INFO: Installing ${font_name} Nerd Font..."
    # Ensure the target directory exists before unzipping
    mkdir -p "${font_target_dir}"
    if curl -fL "${download_url}" -o "${TEMP_DIR}/${zip_file}"; then
        unzip -o "${TEMP_DIR}/${zip_file}" -d "${font_target_dir}" # Unzip directly into the font's directory
        if [ $? -eq 0 ]; then
            echo "SUCCESS: ${font_name} Nerd Font installed."
        else
            echo "ERROR: Failed to unzip ${font_name} Nerd Font."
        fi
    else
        echo "ERROR: Failed to download ${font_name} Nerd Font from ${download_url}."
    fi
}

# Install some popular Nerd Fonts
install_font "FiraCode"
install_font "JetBrainsMono"
install_font "Hack"

echo "INFO: Updating font cache..."
fc-cache -fv &> /dev/null
echo "SUCCESS: Font cache updated."

# Clean up the temporary directory
rm -rf "${TEMP_DIR}"
echo "---------------------------"
