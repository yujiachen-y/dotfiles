#!/bin/sh
echo "🍉 Setting up your machine"

DOTFILES="$HOME/dotfiles"

. "$DOTFILES"/zsh/install.sh

echo "🍉 Setting up vim"
VIMFILE="$HOME/.vimrc"
rm "$VIMFILE"
ln -s "$DOTFILES"/.vimrc "$VIMFILE"

if [ "$(uname)" = "Darwin" ]; then
  . "$DOTFILES"/macos/install.sh
fi
