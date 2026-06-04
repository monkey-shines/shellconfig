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
    openssl neofetch command-not-found

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

# -------------------------------------------------
# PURE BASH-TO-ZSH HISTORY CONVERSION
# -------------------------------------------------
BASH_HIST="$HOME/.bash_history"
ZSH_HIST="$HOME/.zsh_history"

if [ -f "$BASH_HIST" ]; then
    echo "==> Converting .bash_history to a fresh .zsh_history..."
    
    TEMP_HIST=$(mktemp)
    START_TIME=$(($(date +%s) - 8640000)) # 100 days ago runway
    COUNTER=0
    BUFFER=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Trim leading and trailing whitespace
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        # Skip completely empty lines or native Bash timestamp comments
        if [[ -z "$line" ]] || [[ "$line" =~ ^#[0-9]+$ ]]; then
            continue
        fi

        # Check if this line ends with a backslash (multi-line command)
        if [[ "$line" =~ \\$ ]]; then
            # Strip the backslash and append the line to our build buffer
            BUFFER+="${line%\\} "
            continue
        else
            # No backslash, so append this final line to whatever is in the buffer
            BUFFER+="$line"
        fi

        # Clean up any accidental double spaces created by joining lines
        BUFFER=$(echo "$BUFFER" | tr -s ' ')

        # Increment timestamp by 1 second to keep history ordered perfectly
        CURRENT_TIME=$((START_TIME + COUNTER))
        
        # Write out the completed, unified command in Zsh format
        echo ": ${CURRENT_TIME}:0;${BUFFER}" >> "$TEMP_HIST"
        
        # Reset the buffer for the next command sequence
        BUFFER=""
        COUNTER=$((COUNTER + 1))
    done < "$BASH_HIST"

    # Safely write out any remaining content left over in the buffer
    if [[ -n "$BUFFER" ]]; then
        CURRENT_TIME=$((START_TIME + COUNTER))
        echo ": ${CURRENT_TIME}:0;${BUFFER}" >> "$TEMP_HIST"
    fi

    # Wipe out any uninitialized Zsh history and replace it entirely with your converted Bash history
    mv "$TEMP_HIST" "$ZSH_HIST"
    chmod 600 "$ZSH_HIST"
    echo "==> Done. Successfully formatted and imported $COUNTER command lines into Zsh."
fi

# -------------------------------------------------
# AUTOMATIC SHELL SWITCH (ROBUST VERSION)
# -------------------------------------------------
echo "==> Setting Zsh as default shell..."
ZSH_PATH=$(which zsh)

# Fallback chain: Use $USER, if empty use $(id -un), if still empty use $(whoami)
TARGET_USER="${USER:-$(id -un)}"
TARGET_USER="${TARGET_USER:-$(whoami)}"

echo "==> Target account identified as: $TARGET_USER"

# Safely modify the system user profile
sudo usermod -s "$ZSH_PATH" "$TARGET_USER"

echo "==> Done. Restart shell with: exec zsh"
