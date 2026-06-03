# Path
export PATH="$HOME/.local/bin:$PATH"
export TERM="xterm-256color"

# Starship
eval "$(starship init zsh)"

# Plugins (ORDER MATTERS)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

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
