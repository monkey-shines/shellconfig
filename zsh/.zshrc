# Path
export PATH="$HOME/.local/bin:$PATH"
export TERM="xterm-256color"

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

# Source aliases
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.exports ] && source ~/.exports

# Quality of life
setopt autocd
