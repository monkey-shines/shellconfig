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

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Source aliases
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.exports ] && source ~/.exports

# fzf preview with bat
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null'"

# Quality of life
setopt autocd
