# ZSH Plugin loader
# Add your plugin sources here

# Example: Load plugins from Homebrew
# HOMEBREW_PREFIX="$(brew --prefix)"
# [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Example: Load plugins from ~/.zsh/plugins/
# [ -f $ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] && source $ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# [ -f $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# [ -f $ZSH/plugins/zsh-abbr/zsh-abbr.zsh ] && source $ZSH/plugins/zsh-abbr/zsh-abbr.zsh

# Load compinit once after all plugins
autoload -U compinit
compinit
