#!/usr/bin/env bash

set -e

source ./scripts/utils.sh

# Check if git is installed
if ! command -v git &>/dev/null; then
  print_error "Git is not installed. Please install Git first."
  exit 1
fi

print_muted "Setting up Git configuration..."

# Check if gitconfig template exists
if [ ! -f "configs/git/gitconfig" ]; then
  print_error "No gitconfig found in configs/git/gitconfig. Please create one first."
  exit 1
fi

# Flag to track if gitconfig was set up
gitconfig_setup=false

# Setup gitconfig if it doesn't exist or user agrees to override
if [ ! -f "$HOME/.gitconfig" ]; then
  print_muted "Copying gitconfig from configs/git/gitconfig..."
  cp configs/git/gitconfig ~/.gitconfig
  print_success_muted "Copied gitconfig file"
  gitconfig_setup=true
elif files_are_identical "$HOME/.gitconfig" "configs/git/gitconfig"; then
  print_success_muted "Git configuration already up to date"
  gitconfig_setup=true
elif confirm_override "$HOME/.gitconfig" "configs/git/gitconfig" ".gitconfig file"; then
  print_muted "Copying gitconfig from configs/git/gitconfig..."
  cp configs/git/gitconfig ~/.gitconfig
  print_success_muted "Copied gitconfig file"
  gitconfig_setup=true
else
  print_success_muted "Git configuration skipped."
fi

# Prompt for Git user information only if gitconfig is set up
if [ "$gitconfig_setup" = true ]; then
  print_muted "Setting up Git user information..."

  # Prompt for Git name with validation
  while true; do
    echo -n "Enter your Git display name: "
    read git_name </dev/tty
    if [ -n "$git_name" ]; then
      git config --global user.name "$git_name"
      print_success_muted "Git name set to: $git_name"
      break
    else
      print_warning "Git name cannot be empty. Please try again."
    fi
  done

  # Prompt for Git email with validation
  while true; do
    echo -n "Enter your Git email: "
    read git_email </dev/tty
    if [ -n "$git_email" ] && echo "$git_email" | grep -qE '^[^@]+@[^@]+\.[^@]+$'; then
      git config --global user.email "$git_email"
      print_success_muted "Git email set to: $git_email"
      break
    elif [ -z "$git_email" ]; then
      print_warning "Git email cannot be empty. Please try again."
    else
      print_warning "Invalid email format. Please enter a valid email address."
    fi
  done

  print_success "Git setup completed!"
else
  print_success_muted "Git setup completed (configuration skipped)."
fi