#!/usr/bin/env bash

set -e

# Source utility functions
source ./scripts/utils.sh

# set zsh as default shell
if ! command -v zsh &>/dev/null; then
  print_error "ZSH is not installed. Please ensure it's installed via Homebrew first."
  exit 1
fi

# Check if zsh is already the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  step "Setting ZSH as default shell…"
  chsh -s "$(which zsh)"
  print_success "ZSH set as default shell!"
else
  print_success_muted "ZSH is already the default shell. Skipping"
fi

# install oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  print_success_muted "oh-my-zsh already installed. Skipping"
else
  step "Installing oh-my-zsh…"
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    print_success "oh-my-zsh installed!"
  else
    print_warning "oh-my-zsh installation failed. You can install it manually later."
  fi
fi