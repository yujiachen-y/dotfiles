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

# mise resolves core tools (node) before npm-backend tools in a single pass,
# so this works on a fresh machine without nvm/node pre-installed.
echo "🍉   Installing mise-declared tools"
mise install
