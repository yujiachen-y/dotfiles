#!/bin/sh
echo "🍉 Setting up mac"
MACOS_FOLDER="$HOME/dotfiles/macos"

# TODO
#  Setup proxy to speedup download process:
#  Alternative 1: setup a global proxy first.
#  Alternative 2: setup mirror sites for different sources.
# if [ ! -d "/Applications/ClashX.app" ]; then
#   echo "please setup proxy first!"
#   # FIXME
#   #  You may need to check out the below link to implenment the installing process:
#   #  https://apple.stackexchange.com/questions/73926/is-there-a-command-to-install-a-dmg
# fi

echo "🍉     Setting up brew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
brew bundle --file "$MACOS_FOLDER"/Brewfile

# I need more time to learn macos before I can use this script confidently.
# echo "🍉     Setting up system preference"
# . "$MACOS_FOLDER"/sys_prefer.sh
