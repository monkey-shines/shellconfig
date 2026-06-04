# Path
export PATH="$HOME/.local/bin:$PATH"
export TERM="xterm-256color"

# Starship
eval "$(starship init zsh)"

# Plugins (ORDER MATTERS)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Critical flags telling Zsh to read extended strings and immediately commit keys
setopt EXTENDED_HISTORY      # Tells Zsh to read/write the ': timestamp:0;' format
setopt SHARE_HISTORY         # Shares history across multiple open terminal panes instantly
setopt APPEND_HISTORY        # Appends commands to the file instead of overwriting it
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not just on shell exit

# -------------------------------------------------
# HISTORY CONFIGURATION
# -------------------------------------------------
HISTFILE="$HOME/.zsh_history"  # Where Zsh saves your terminal command history
HISTSIZE=50000                 # How many commands to keep in active memory
SAVEHIST=50000                 # How many commands to save inside the history file

setopt EXTENDED_HISTORY      # Saves Unix timestamps so commands show exactly when they ran
setopt SHARE_HISTORY         # Instantly shares command history across all open terminal windows
setopt APPEND_HISTORY        # Appends new commands to the file instead of overwriting it
setopt INC_APPEND_HISTORY    # Saves commands to the file immediately when hit enter, not at exit
setopt HIST_FIND_NO_DUPS     # Saves 100% of duplicates to file, but skips them while arrow-searching

# Better completion
autoload -Uz compinit && compinit

# Source aliases & exports
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.functions ] && source ~/.functions

# Quality of life
setopt autocd

# -------------------------------------------------
# CUSTOM KEYBIND OVERRIDES (ALWAYS PUT THIS LAST)
# -------------------------------------------------
typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Delete]="${terminfo[kdch1]}"

[[ -n "${key[Home]}" ]] && bindkey -- "${key[Home]}" beginning-of-line
[[ -n "${key[End]}" ]]  && bindkey -- "${key[End]}" end-of-line
[[ -n "${key[Delete]}" ]] && bindkey -- "${key[Delete]}" delete-char

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
