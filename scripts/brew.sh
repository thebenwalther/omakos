#! /bin/bash

set -e

source ./scripts/utils.sh

step "Installing Homebrew packages from configs/Brewfile"

# Check if Brewfile exists
if [ ! -f "configs/Brewfile" ]; then
  print_error "Brewfile not found at configs/Brewfile"
  exit 1
fi

echo ""
echo "--------------------------------------------------------"
brew bundle --file=configs/Brewfile
echo "--------------------------------------------------------"
print_success "Homebrew packages installed!"