#!/usr/bin/env bash
# trap 'read -p "Press Enter to run: $BASH_COMMAND"' DEBUG
set -e

REPO="https://github.com/monkey-shines/shellconfig.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y zsh git curl unzip htop wget tmux

echo "==> Installing Starship..."
if ! command -v starship >/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo "==> Cloning dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO" "$DOTFILES_DIR"
else
    git -C "$DOTFILES_DIR" pull
fi

echo "==> Preparing directories..."
mkdir -p "$HOME/.config"

echo "==> Linking config files..."

link_file () {
    local src="$1"
    local dest="$2"

    rm -rf "$dest"
    ln -s "$src" "$dest"
}

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/zsh/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/zsh/.exports" "$HOME/.exports"

echo "==> Installing modern CLI tools..."
sudo apt install -y eza ripgrep bat || true

# Fallback for eza
if ! command -v eza >/dev/null; then
    echo "Installing eza manually..."
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
        sudo gpg --dearmor -o /etc/apt/keyrings/eza.gpg

    echo "deb [signed-by=/etc/apt/keyrings/eza.gpg] \
http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/eza.list

    sudo apt install -y eza
fi

echo "==> Installing Zsh plugins..."

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

if [ ! -d "$ZSH_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_DIR/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_DIR/zsh-syntax-highlighting"
fi

# Optional: skip fonts in Docker
# This is only needed if it is a local shell directly on a host machine - leaving out for now
# if [ ! -f /.dockerenv ]; then
#    echo "==> Installing fonts..."
#    bash "$DOTFILES_DIR/fonts/install-fonts.sh"
# else
#    echo "==> Skipping font install (Docker)"
#fi

# Had some trouble with this not running as sudo or with permission -- do it manually
# echo "==> Setting default shell..."
# chsh -s "$(which zsh)" || true

echo "==> Done. Restart your shell or run: zsh"
echo "==> run chsh -s <path-to-your-zsh> to change your shell"
