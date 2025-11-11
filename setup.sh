#!/usr/bin/env bash

###############################################################################
# ERROR: Let the user know if the script fails
###############################################################################

# Exit handler - runs if script fails
trap 'if [ $? -ne 0 ]; then
  echo -e "\n   ❌ Omakos setup failed"
  exit $?
fi' EXIT

set -e

# Source utility functions
source ./scripts/utils.sh

# Initialize chapter counter
count=1

chapter() {
  local fmt="$1"
  shift
  printf "\n✦  ${bold}$((count++)). $fmt${normal}\n└─────────────────────────────────────────────────────○\n" "$@"
}

###############################################################################
# Initial Ascii Art and Introduction
###############################################################################

source ./scripts/ascii.sh

printf "\nWelcome to Omakos! 🚀\n"
printf "Omakos turns your new mac laptop into a full configured development system in a single command.\n"
printf "It is safe to rerun this multiple times.\n"
printf "You can cancel at any time by pressing ctrl+c.\n"
printf "Let's get started!\n"

###############################################################################
# CHECK: Internet
###############################################################################
chapter "Checking internet connection…"
check_internet_connection

###############################################################################
# PROMPT: Password
###############################################################################
chapter "Caching password…"
ask_for_sudo

###############################################################################
# INSTALL: Dependencies
###############################################################################
chapter "Installing Dependencies…"

# -----------------------------------------------------------------------------
# XCode
# -----------------------------------------------------------------------------
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
  print_success_muted 'Command-line tools already installed. Skipping'
else
  step 'Installing Command-line tools...'
  in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch "${in_progress}"
  product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
  if ! softwareupdate --verbose --install "${product}"; then
    echo 'Installation failed.' 1>&2
    rm "${in_progress}"
    exit 1
  fi
  rm "${in_progress}"
  print_success 'Installation succeeded.'
fi

# -----------------------------------------------------------------------------
# Touch ID for sudo
# -----------------------------------------------------------------------------
step "Setting up Touch ID for sudo authentication..."
if [ -f /etc/pam.d/sudo_local.template ]; then
  if sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null 2>&1; then
    print_success "Touch ID enabled for sudo"
  else
    print_muted "Touch ID setup skipped (will use password authentication)"
  fi
else
  print_muted "Touch ID template not found (will use password authentication)"
fi

# -----------------------------------------------------------------------------
# Git Repository Initialization (for submodules)
# -----------------------------------------------------------------------------
# Initialize git repo if this was installed via zip download
# This allows submodules (like zsh-abbr) to be properly initialized later
if [ ! -d ".git" ] && [ -f ".gitmodules" ] && command -v git &>/dev/null; then
  step "Initializing git repository for submodules..."
  git init -q
  git remote add origin https://github.com/thebenwalther/omakos.git 2>/dev/null || true
  print_success_muted "Git repository initialized"
elif [ ! -d ".git" ] && [ -f ".gitmodules" ]; then
  print_warning "Git not available yet. Submodules will be initialized when ZSH setup runs."
fi

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------
if ! [ -x "$(command -v brew)" ]; then
  step "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$(uname -p)" == "arm" ]]; then
    # Apple Silicon M1/M2 Macs
    export PATH=/opt/homebrew/bin:$PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel Macs
    export PATH=/usr/local/bin:$PATH
  fi
  print_success "Homebrew installed!"
else
  print_success_muted "Homebrew already installed. Updating Homebrew formulae…"
  brew update --quiet >/dev/null 2>&1
fi

###############################################################################
# INSTALL: Homebrew Packages
###############################################################################
chapter "Installing Homebrew Packages…"
source ./scripts/brew.sh

###############################################################################
# INSTALL: Setup ZSH and Starship
###############################################################################
chapter "Setting up ZSH with Starship…"
source ./scripts/zsh.sh

###############################################################################
# SETUP: Neovim
###############################################################################
chapter "Setting up Neovim…"
source ./scripts/nvim.sh

###############################################################################
# SETUP: Zed
###############################################################################
chapter "Setting up Zed…"
source ./scripts/zed.sh

###############################################################################
# SETUP: Git
###############################################################################
chapter "Setting up Git…"
source ./scripts/git.sh

###############################################################################
# SETUP: SSH
###############################################################################
chapter "Setting up SSH…"
source ./scripts/ssh.sh

###############################################################################
# SETUP: Rubocop
###############################################################################
chapter "Setting up Rubocop…"
source ./scripts/rubocop.sh

###############################################################################
# SETUP: Gemrc
###############################################################################
chapter "Setting up Gem configuration…"
source ./scripts/gemrc.sh

###############################################################################
# SETUP: IRB
###############################################################################
chapter "Setting up IRB configuration…"
source ./scripts/irbrc.sh

###############################################################################
# SETUP: Zshrc
###############################################################################
chapter "Setting up Zsh configuration…"
source ./scripts/zshrc.sh

###############################################################################
# SETUP: Ghostty
###############################################################################
chapter "Setting up Ghostty…"
source ./scripts/ghostty.sh

###############################################################################
# SETUP: Development Tools with mise
###############################################################################
chapter "Setting up Development Tools…"
source ./scripts/mise.sh

###############################################################################
# SETUP: Mac Settings
###############################################################################
chapter "Setting up Mac Settings…"
source ./scripts/mac.sh

###############################################################################
# SETUP: Complete
###############################################################################
chapter "Setup Complete!"
print_success "Your Mac is now ready to use! 🎉"
print_success_muted "You may need to restart your computer for all changes to take effect."
