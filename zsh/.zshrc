# Path
export PATH="$HOME/.local/bin:$PATH"

# Starship
eval "$(starship init zsh)"

# Plugins (ORDER MATTERS)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# Better completion
autoload -Uz compinit && compinit

# Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --group-directories-first"
alias la="eza -a --icons"

# Quality of life
setopt autocd
