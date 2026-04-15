#!/usr/bin/env bash
set -e

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "==> Downloading JetBrainsMono Nerd Font..."
curl -fLo JetBrainsMono.zip \
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip

unzip JetBrainsMono.zip -d JetBrainsMono

echo "==> Installing fonts..."
cp JetBrainsMono/*.ttf "$FONT_DIR"

echo "==> Refreshing font cache..."
fc-cache -fv

echo "==> Done. Set your terminal font to 'JetBrainsMono Nerd Font'."
