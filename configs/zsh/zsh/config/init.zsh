# Tool initializations

# Initialize mise (formerly rtx) for version management
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Initialize zoxide (smart cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Initialize fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi
