#!/bin/sh
MACOS_FOLDER="$HOME/dotfiles/macos"

echo "🍉     Setting up brew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
brew bundle --file "$MACOS_FOLDER"/Brewfile

echo "🍉     Setting up ghostty"
GHOSTTY_DIR="$HOME/.config/ghostty"
mkdir -p "$GHOSTTY_DIR"
GHOSTTY_CONFIG="$GHOSTTY_DIR/config"
if [ -e "$GHOSTTY_CONFIG" ] || [ -L "$GHOSTTY_CONFIG" ]; then
  rm "$GHOSTTY_CONFIG"
fi
ln -s "$MACOS_FOLDER/ghostty/config" "$GHOSTTY_CONFIG"

echo "🍉     Setting up system settings"
"$MACOS_FOLDER"/system_settings.sh
