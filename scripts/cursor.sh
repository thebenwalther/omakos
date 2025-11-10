#!/usr/bin/env bash

set -e

source ./scripts/utils.sh

# Check if Cursor is installed via Homebrew
if ! brew list --cask | grep -q "^cursor$"; then
  print_error "Cursor is not installed. Please ensure it was installed via Homebrew"
  exit 1
fi

# Create Cursor config directories if they don't exist
CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor"
CURSOR_USER_DIR="$CURSOR_CONFIG_DIR/User"

step "Setting up Cursor configuration directories..."
mkdir -p "$CURSOR_USER_DIR"

# Backup existing settings if they exist
if [ -f "$CURSOR_USER_DIR/settings.json" ]; then
  step "Backing up existing Cursor settings..."
  cp "$CURSOR_USER_DIR/settings.json" "$CURSOR_USER_DIR/settings.json.backup"
fi

# Copy new settings
step "Installing Cursor settings..."
if [ ! -f "configs/cursor/settings.json" ]; then
  print_warning "Settings file not found at configs/cursor/settings.json. Skipping."
else
  cp configs/cursor/settings.json "$CURSOR_USER_DIR/settings.json"
  print_success_muted "Settings installed successfully!"
fi

# Install extensions
step "Installing Cursor extensions..."
if [ -f "configs/cursor/extensions.txt" ]; then
  CURSOR_PATH="/Applications/Cursor.app/Contents/MacOS/Cursor"
  if [ ! -f "$CURSOR_PATH" ]; then
    print_error "Cursor executable not found at: $CURSOR_PATH"
    exit 1
  fi

  success_count=0
  fail_count=0

  while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip empty lines and comments
    if [ -z "$extension" ] || [[ "$extension" =~ ^[[:space:]]*# ]]; then
      continue
    fi

    print_muted "Installing extension: $extension"
    if "$CURSOR_PATH" --install-extension "$extension" >/dev/null 2>&1; then
      ((success_count++))
    else
      print_warning "Failed to install extension: $extension"
      ((fail_count++))
    fi
  done <"configs/cursor/extensions.txt"

  if [ $fail_count -eq 0 ]; then
    print_success_muted "All extensions installed successfully! ($success_count installed)"
  else
    print_warning "Extensions installation completed with errors. Success: $success_count, Failed: $fail_count"
  fi
else
  print_warning "Extensions file not found at configs/cursor/extensions.txt"
fi

print_success "Cursor setup completed!"