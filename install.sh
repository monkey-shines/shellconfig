#!/usr/bin/env bash
set -e

REPO="https://github.com/monkey-shines/shellconfig.git"
DOTFILES_DIR="$HOME/.dotfiles"

# -------------------------------------------------
# HARDENED NON-INTERACTIVE MODE (CRITICAL)
# -------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

echo "==> Updating package index..."
sudo -E apt update -y

# -------------------------------------------------
# BASE SYSTEM PACKAGES
# -------------------------------------------------
echo "==> Installing base system packages..."
sudo -E apt install -y \
    zsh git curl unzip htop wget tmux \
    dnsutils net-tools iproute2 traceroute \
    sysstat lsof ripgrep ncdu nmap \
    openssl command-not-found

# -------------------------------------------------
# TIMEZONE (SAFE + NON-INTERACTIVE)
# DO NOT PROMPT, DO NOT OVERRIDE USER SETTINGS
# -------------------------------------------------
echo "==> Ensuring tzdata is installed (no prompts)..."
sudo -E apt install -y tzdata
sudo ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime || true

# -------------------------------------------------
# STARSHIP PROMPT
# -------------------------------------------------
echo "==> Installing Starship..."
if ! command -v starship >/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# -------------------------------------------------
# DOTFILES
# -------------------------------------------------
echo "==> Cloning dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO" "$DOTFILES_DIR"
else
    git -C "$DOTFILES_DIR" pull
fi

echo "==> Linking config files..."
mkdir -p "$HOME/.config"

link_file () {
    local src="$1"
    local dest="$2"
    rm -rf "$dest"
    ln -s "$src" "$dest"
}

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/zsh/.exports" "$HOME/.exports"
link_file "$DOTFILES_DIR/zsh/.functions" "$HOME/.functions"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# -------------------------------------------------
# MODERN CLI TOOLS
# -------------------------------------------------
echo "==> Installing modern CLI tools..."
sudo -E apt install -y eza bat || true

if ! command -v eza >/dev/null; then
    echo "==> Installing eza fallback..."
    sudo -E apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
        sudo gpg --dearmor -o /etc/apt/keyrings/eza.gpg

    echo "deb [signed-by=/etc/apt/keyrings/eza.gpg] http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/eza.list >/dev/null

    sudo apt update
    sudo apt install -y eza
fi

# -------------------------------------------------
# ZSH PLUGINS
# -------------------------------------------------
echo "==> Installing Zsh plugins..."
ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

if [ ! -d "$ZSH_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_DIR/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_DIR/zsh-syntax-highlighting"
fi

echo "==> Done. Restart shell with: exec zsh"
echo "==> Dont forget to change shells with chsh -s /usr/bin/zsh or similar"
