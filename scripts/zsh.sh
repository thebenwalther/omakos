#!/usr/bin/env bash

set -e

# Source utility functions
source ./scripts/utils.sh

# set zsh as default shell
if ! command -v zsh &>/dev/null; then
  print_error "ZSH is not installed. Please ensure it's installed via Homebrew first."
  exit 1
fi

# Get the path to Homebrew zsh
ZSH_PATH="$(which zsh)"

# Add Homebrew zsh to /etc/shells if not already present
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
  step "Adding $ZSH_PATH to /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  print_success_muted "Added to /etc/shells"
else
  print_success_muted "$ZSH_PATH already in /etc/shells"
fi

# Check if zsh is already the default shell
if [ "$SHELL" != "$ZSH_PATH" ]; then
  step "Setting ZSH as default shell…"
  chsh -s "$ZSH_PATH"
  print_success "ZSH set as default shell!"
else
  print_success_muted "ZSH is already the default shell. Skipping"
fi

# Check if Starship is installed
if ! command -v starship &>/dev/null; then
  print_error "Starship is not installed. Please ensure it's installed via Homebrew first."
  exit 1
fi

# Setup Starship configuration
mkdir -p "$HOME/.config"

if [ -f "./configs/starship.toml" ]; then
  step "Setting up Starship configuration..."
  if [ ! -f "$HOME/.config/starship.toml" ]; then
    cp "./configs/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship configuration installed"
  elif files_are_identical "$HOME/.config/starship.toml" "./configs/starship.toml"; then
    print_success_muted "Starship configuration already up to date"
  elif confirm_override "$HOME/.config/starship.toml" "./configs/starship.toml" "Starship configuration"; then
    cp "./configs/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship configuration installed"
  else
    print_muted "Skipping Starship configuration"
  fi
else
  print_warning "Starship configuration file not found at configs/starship.toml"
fi

print_success "ZSH with Starship setup completed!"