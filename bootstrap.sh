#!/usr/bin/env bash
set -euo pipefail

# Minimal bootstrap for macOS.

echo "Starting macOS bootstrap..."

# --- Prerequisites ---

# Ask for sudo upfront to cache credentials
if [ "$(id -u)" -ne 0 ]; then
  sudo -v || true
fi

# Ensure Command Line Tools are installed
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Command Line Tools not found — installing (this will prompt a GUI)."
  if ! xcode-select --install 2>/dev/null; then
    echo "xcode-select --install returned non-zero. If you cancelled or it failed, please run 'xcode-select --install' manually and re-run this script."
  fi
else
  echo "Command Line Tools already installed."
fi

# --- Homebrew ---

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

# --- Git ---

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
  echo "git not found — installing via Homebrew..."
  brew install git
else
  echo "git present: $(git --version)"
fi

# Create a ~/.gitconfig
if [ -f "$HOME/.gitconfig" ]; then
  read -r -p "$HOME/.gitconfig exists — overwrite? [y/N] " overwrite_reply
  if [[ ! $overwrite_reply =~ ^[Yy]$ ]]; then
    echo "Keeping existing $HOME/.gitconfig"
    GITCONFIG_SKIP=1
  fi
fi

if [ -z "${GITCONFIG_SKIP:-}" ]; then
  if [ -n "${GIT_NAME:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
    name="$GIT_NAME"
    email="$GIT_EMAIL"
  else
    read -r -p "Git user.name: " name
    read -r -p "Git user.email: " email
  fi

  cat > "$HOME/.gitconfig" <<EOF
[user]
  name = $name
  email = $email
EOF

  echo "Wrote $HOME/.gitconfig"
fi

# --- Development Tools ---

# Install tools via Homebrew
if command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew formulae: gh, oh-my-posh, uv..."
  brew install gh jandedobbeleer/oh-my-posh/oh-my-posh uv || true
  
  echo "Installing Homebrew casks: claude-code, warp..."
  brew install --cask claude-code || true
  brew install --cask warp || true
else
  echo "Homebrew not found; skipping package installs."
fi

# Install Fira Code Nerd Font
if command -v oh-my-posh >/dev/null 2>&1; then
  echo "Installing Fira Code Nerd Font..."
  oh-my-posh font install FiraCode
else
  echo "Oh My Posh not found; skipping Fira Code Nerd Font install"
fi

# Install nvm (Node Version Manager)
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

# Install global npm packages
if command -v npm >/dev/null 2>&1; then
  echo "Installing global npm packages: @google/gemini-cli, pnpm..."
  npm install -g @google/gemini-cli pnpm
else
  echo "npm not found; skipping global npm package installation."
fi

# Install latest Python via uv
if command -v uv >/dev/null 2>&1; then
  echo "Installing latest Python via uv..."
  uv python install --default
  uv python update-shell
  uv tool install ruff
else
  echo "uv not found; skipping Python installation."
fi

# --- macOS Settings ---

echo "Configuring macOS settings..."

# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Dock, Dashboard, and Hot Corners
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 72
defaults write com.apple.dock autohide -bool true

read -r -p "Do you want to unpin all apps from the Dock? (y/N) " reply
if [[ $reply =~ ^[Yy]$ ]]; then
  echo "Unpinning all apps from the Dock..."
  defaults write com.apple.dock persistent-apps -array
else
  echo "Keeping existing Dock applications."
fi

defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Menu Bar
defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Display" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Sound" -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Keyboard Shortcuts
if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
  /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled bool false" ~/Library/Preferences/com.apple.symbolichotKeys.plist
else
  echo "PlistBuddy not found, skipping Spotlight shortcut disabling."
fi
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

# Trackpad & Mouse
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.0
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.0
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool false
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Apply changes ---

echo "Applying changes..."
killall Dock
killall SystemUIServer

echo "Bootstrap complete."
