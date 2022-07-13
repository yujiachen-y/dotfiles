#!/bin/sh
echo "🍉 Setting up your machine"

DOTFILES="$HOME/dotfiles"

echo "🍉 Setting up vim"
VIMRC="$HOME/.vimrc"
rm "$VIMRC"
ln -s "$DOTFILES"/.vimrc "$VIMRC"

if [ "$(uname)" = "Darwin" ]; then
  . "$DOTFILES"/macos/install.sh
fi

. "$DOTFILES"/zsh/install.sh

echo "🍉 Setting up git"
GITCONFIG="$HOME/.gitconfig"
rm "$GITCONFIG"
ln -s "$DOTFILES"/.gitconfig "$GITCONFIG"