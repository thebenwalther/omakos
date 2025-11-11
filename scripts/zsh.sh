#!/usr/bin/env bash

set -e

# Source utility functions
source ./scripts/utils.sh

# Initialize git submodules (for plugins like zsh-abbr)
if [ -f ".gitmodules" ]; then
  step "Initializing ZSH plugin submodules..."
  git submodule update --init --recursive configs/zsh/zsh/plugins/ 2>/dev/null || true
  print_success_muted "Plugin submodules initialized"
fi

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

# Setup ZSH configuration structure
step "Setting up ZSH configuration..."

# Copy .zshenv to home directory (sets ZDOTDIR to ~/.zsh)
if [ -f "./configs/zsh/.zshenv" ]; then
  if [ ! -f "$HOME/.zshenv" ]; then
    cp "./configs/zsh/.zshenv" "$HOME/.zshenv"
    print_success_muted "~/.zshenv created"
  elif files_are_identical "$HOME/.zshenv" "./configs/zsh/.zshenv"; then
    print_success_muted "~/.zshenv already up to date"
  elif confirm_override "$HOME/.zshenv" "./configs/zsh/.zshenv" ".zshenv"; then
    cp "./configs/zsh/.zshenv" "$HOME/.zshenv"
    print_success_muted "~/.zshenv updated"
  else
    print_muted "Skipping .zshenv"
  fi
else
  print_warning ".zshenv not found in configs/zsh/"
fi

# Copy bootstrap .zshrc to home directory
if [ -f "./configs/zsh/.zshrc" ]; then
  if [ ! -f "$HOME/.zshrc" ]; then
    cp "./configs/zsh/.zshrc" "$HOME/.zshrc"
    print_success_muted "~/.zshrc created"
  elif files_are_identical "$HOME/.zshrc" "./configs/zsh/.zshrc"; then
    print_success_muted "~/.zshrc already up to date"
  elif confirm_override "$HOME/.zshrc" "./configs/zsh/.zshrc" ".zshrc"; then
    cp "./configs/zsh/.zshrc" "$HOME/.zshrc"
    print_success_muted "~/.zshrc updated"
  else
    print_muted "Skipping .zshrc"
  fi
else
  print_warning ".zshrc not found in configs/zsh/"
fi

# Copy the entire ~/.zsh directory structure
if [ -d "./configs/zsh/zsh" ]; then
  mkdir -p "$HOME/.zsh"

  # Copy all subdirectories and files
  if [ -d "./configs/zsh/zsh/config" ]; then
    mkdir -p "$HOME/.zsh/config"
    cp -r ./configs/zsh/zsh/config/* "$HOME/.zsh/config/" 2>/dev/null || true
    print_success_muted "ZSH config files copied"
  fi

  if [ -d "./configs/zsh/zsh/plugins" ]; then
    mkdir -p "$HOME/.zsh/plugins"
    cp -r ./configs/zsh/zsh/plugins/* "$HOME/.zsh/plugins/" 2>/dev/null || true
    print_success_muted "ZSH plugin loader copied"
  fi

  # Copy .zprofile and main .zshrc
  [ -f "./configs/zsh/zsh/.zprofile" ] && cp "./configs/zsh/zsh/.zprofile" "$HOME/.zsh/.zprofile"
  [ -f "./configs/zsh/zsh/.zshrc" ] && cp "./configs/zsh/zsh/.zshrc" "$HOME/.zsh/.zshrc"

  print_success "ZSH configuration installed to ~/.zsh/"
else
  print_warning "ZSH configuration directory not found at configs/zsh/zsh/"
fi

print_success "ZSH with Starship setup completed!"
