#!/bin/sh
# Please note this script has never been ran yet, it's just wrote in advance.

echo "Setting up your machine..."

DOTFILES=$(dirname "$0")

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf "$HOME"/.zshrc
ln -s "$HOME"/.dotfiles/.zshrc "$HOME"/.zshrc

# Set macOS preferences - we will run this last because this will reload the shell
if [ "$(uname)" = "Darwin" ]; then
  . "$DOTFILES"/macos/install.sh
fi
