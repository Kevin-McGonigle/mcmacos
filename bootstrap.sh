#!/usr/bin/env bash
set -euo pipefail

# Minimal bootstrap for macOS.

echo "Starting macOS bootstrap..."

# Ask for sudo upfront to cache credentials
if [ "$(id -u)" -ne 0 ]; then
  sudo -v || true
fi

# Ensure Command Line Tools (interactive install is fine)
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Command Line Tools not found — installing (this will prompt a GUI)."
  if ! xcode-select --install 2>/dev/null; then
    echo "xcode-select --install returned non-zero. If you cancelled or it failed, please run 'xcode-select --install' manually and re-run this script."
  fi
else
  echo "Command Line Tools already installed."
fi

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Make brew available in this shell (supports Apple Silicon and Intel paths)
  echo >> $HOME/.zprofile
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
  fi
else
  echo "Homebrew already installed: $(brew --version | head -n1)"
  read -r -p "Run 'brew update && brew upgrade && brew cleanup'? [y/N] " reply
  if [[ $reply =~ ^[Yy]$ ]]; then
    echo "Updating Homebrew and upgrading packages..."
    brew update
    brew upgrade
    brew cleanup
  else
    echo "Skipping Homebrew update/upgrade."
  fi
fi

# Ensure git is available (install via Homebrew if needed)
if ! command -v git >/dev/null 2>&1; then
  echo "git not found — installing via Homebrew..."
  brew install git
else
  echo "git present: $(git --version)"
fi

# Copy repository .gitconfig to the user's home directory if present.
# Prompt before overwriting an existing $HOME/.gitconfig.
REPO_GITCONFIG="$(pwd)/.gitconfig"
if [ -f "$REPO_GITCONFIG" ]; then
  if [ -f "$HOME/.gitconfig" ]; then
    read -r -p "$HOME/.gitconfig exists — overwrite with repo .gitconfig? [y/N] " overwrite_reply
    if [[ $overwrite_reply =~ ^[Yy]$ ]]; then
      cp "$REPO_GITCONFIG" "$HOME/.gitconfig"
      echo "Copied .gitconfig to $HOME/.gitconfig"
    else
      echo "Leaving existing $HOME/.gitconfig in place."
    fi
  else
    cp "$REPO_GITCONFIG" "$HOME/.gitconfig"
    echo "Copied .gitconfig to $HOME/.gitconfig"
  fi
else
  echo "No .gitconfig in repository to copy."
fi

# Install required apps inline
if command -v brew >/dev/null 2>&1; then
  echo "Installing required packages: gh, uv, warp..."
  brew install gh uv || true
  brew install --cask --no-quarantine warp || true
else
  echo "Homebrew not found; skipping package installs."
fi

## Install nvm (Node Version Manager) from latest release using `gh` when available.
# Set PROFILE so the nvm install script persists to the intended profile file.
if command -v gh >/dev/null 2>&1; then
  NVM_TAG=$(gh api repos/nvm-sh/nvm/releases/latest --jq .tag_name 2>/dev/null || true)
  if [ -n "$NVM_TAG" ]; then
    NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_TAG/install.sh"
  else
    NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
  fi
else
  NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
fi

echo "Installing nvm (latest release)..."
curl -fsSL "$NVM_INSTALL_URL" | PROFILE="$HOME/.zprofile" bash

# Load nvm (and bash_completion) into the current session if installed.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install latest LTS Node.js via nvm
if command -v nvm >/dev/null 2>&1; then
  echo "Installing latest LTS Node.js via nvm..."
  nvm install --lts
else
  echo "nvm not found; skipping Node.js installation."
fi

# Install latest Python via uv
if command -v uv >/dev/null 2>&1; then
  echo "Installing latest Python via uv..."
  uv python install --default
  uv python update-shell
else
  echo "uv not found; skipping Python installation."
fi

echo "Bootstrap complete."
