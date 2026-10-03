#!/bin/sh
MACOS_FOLDER="$HOME/dotfiles/macos"

echo "🍉     Setting up brew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
# --verbose streams `brew install` to the tty so downloads show progress bars.
brew bundle --verbose --file "$MACOS_FOLDER"/Brewfile

echo "🍉     Setting up otty"
# shellcheck source=/dev/null
. "$MACOS_FOLDER"/otty/install.sh

echo "🍉     Setting up zed"
# shellcheck source=/dev/null
. "$MACOS_FOLDER"/zed/install.sh

echo "🍉     Setting up system settings"
"$MACOS_FOLDER"/system_settings.sh
