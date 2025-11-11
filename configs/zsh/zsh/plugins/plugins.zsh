# ZSH Plugin loader

### ---- Homebrew-installed plugins -----------------------------------

HOMEBREW_PREFIX="$(brew --prefix)"

# Fast syntax highlighting
if [ -f "$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# Autosuggestions with paste optimization
if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # Autosuggestion highlighting
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

  # This speeds up pasting w/ autosuggest
  # https://github.com/zsh-users/zsh-autosuggestions/issues/238
  pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
  }

  pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
  }
  zstyle :bracketed-paste-magic paste-init pasteinit
  zstyle :bracketed-paste-magic paste-finish pastefinish
fi

### ---- Manual plugins from ~/.zsh/plugins/ -----------------------------------
# Add manual plugin sources here if you clone repos to ~/.zsh/plugins/
# Example:
# [ -f $ZSH/plugins/plugin-name/plugin-name.zsh ] && source $ZSH/plugins/plugin-name/plugin-name.zsh

### ---- Completion system -----------------------------------
# Load compinit once after all plugins
# Using -u flag to skip security check for Homebrew directories
# (Safe for single-user systems; Homebrew dirs are often group-writable)
autoload -U compinit
compinit -u
