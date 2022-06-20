#!/bin/sh
# Please note this script has never been ran yet, it's just wrote in advance.

echo "Setting up your Mac..."

DOTFILES=$(dirname "$0")

# TODO
#  Setup proxy to speedup download process:
#  Alternative 1: setup a global proxy first.
#  Alternative 2: setup mirror sites for different sources.
if [ ! -d "/Applications/ClashX.app" ]; then
  echo "please setup proxy first!"
  # FIXME
  #  You may need to check out the below link to implenment the installing process:
  #  https://apple.stackexchange.com/questions/73926/is-there-a-command-to-install-a-dmg
fi

# Check for Oh My Zsh and install if we don't have it
if test ! "$(which omz)"; then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf "$HOME"/.zshrc
ln -s "$HOME"/.dotfiles/.zshrc "$HOME"/.zshrc

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
# TODO
#  Setup and use Mas (Mac App Store manager) in Brewfile
brew tap homebrew/bundle
brew bundle --file "$DOTFILES"/Brewfile

# Symlink the Mackup config file to the home directory
# FIXME
#  Setup mackup for your current configurationsj.
ln -s "$DOTFILES"/.mackup.cfg "$HOME"/.mackup.cfg

# Set macOS preferences - we will run this last because this will reload the shell
# shellcheck source="$DOTFILES"/.macos
# shellcheck source=/dev/null
. "$DOTFILES"/.macos
