#!/bin/sh
MACOS_FOLDER="$HOME/dotfiles/macos"

echo "🍉     Setting up brew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
brew bundle --file "$MACOS_FOLDER"/Brewfile

echo "🍉     Setting up zed"
# shellcheck source=/dev/null
. "$MACOS_FOLDER"/zed/install.sh

echo "🍉     Setting up system settings"
"$MACOS_FOLDER"/system_settings.sh
