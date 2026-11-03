#!/bin/bash
# install-scripts/install_cli_tools.sh
# Prebuilt CLI binaries from GitHub releases, installed to ~/.local/bin (no sudo).
# Replaces the copies that used to be committed in bin/.

echo "--- Installing CLI tools (jless, jtd-infer) ---"

DEST="$HOME/.local/bin"
mkdir -p "$DEST"

# install_release <cmd> <repo> <asset name; {v} = tag>
install_release() {
    local cmd="$1" repo="$2" asset_tpl="$3"
    if command -v "$cmd" &> /dev/null; then
        echo "SUCCESS: $cmd is already installed ($(command -v "$cmd"))."
        return 0
    fi
    local tag
    tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep -Po '"tag_name": *"\K[^"]*')
    if [ -z "$tag" ]; then
        echo "ERROR: Could not fetch latest $cmd release."
        return 1
    fi
    local asset="${asset_tpl//\{v\}/$tag}"
    local tmp
    tmp=$(mktemp -d)
    echo "INFO: Downloading $cmd $tag..."
    if curl -fsSLo "$tmp/pkg.zip" "https://github.com/${repo}/releases/download/${tag}/${asset}" \
        && unzip -q -o "$tmp/pkg.zip" -d "$tmp" \
        && install -m 755 "$tmp/$cmd" "$DEST/$cmd"; then
        echo "SUCCESS: $cmd $tag installed to $DEST."
    else
        echo "ERROR: Failed to install $cmd."
    fi
    rm -rf "$tmp"
}

install_release jless     PaulJuliusMartinez/jless     "jless-{v}-x86_64-unknown-linux-gnu.zip"
install_release jtd-infer jsontypedef/json-typedef-infer "x86_64-unknown-linux-musl.zip"

echo "-----------------------------------------------"
