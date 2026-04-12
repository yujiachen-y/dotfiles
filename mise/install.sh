#!/bin/sh
# Sets up mise configuration and installs declared tools.
# mise itself is installed via macos/Brewfile (or OS-specific method).

echo "🍉   Setting up mise"
MISE_DOTFILES="$HOME/dotfiles/mise"
MISE_CONFIG_DIR="$HOME/.config/mise"

if ! command -v mise >/dev/null 2>&1; then
  echo "🍉   mise not found, skipping. Install via brew bundle first."
  exit 0
fi

mkdir -p "$MISE_CONFIG_DIR"

MISE_CONFIG="$MISE_CONFIG_DIR/config.toml"
if [ -e "$MISE_CONFIG" ] || [ -L "$MISE_CONFIG" ]; then
  rm "$MISE_CONFIG"
fi
ln -s "$MISE_DOTFILES/config.toml" "$MISE_CONFIG"

# Load nvm so mise's npm backend can find node/npm.
# nvm is loaded in .zshrc at interactive-shell runtime, but this script
# runs in /bin/sh where .zshrc hasn't been sourced.
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  . "/opt/homebrew/opt/nvm/nvm.sh" >/dev/null 2>&1
fi

if command -v npm >/dev/null 2>&1; then
  echo "🍉   Installing mise-declared tools"
  mise install
else
  echo "🍉   npm not found (nvm or node missing). Run 'mise install' manually after first 'nvm install --lts'."
fi
