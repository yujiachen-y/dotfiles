#!/bin/sh
echo "🍉 Setting up your machine"

DOTFILES="$HOME/dotfiles"

echo "🍉 Setting up vim"
VIMRC="$HOME/.vimrc"
if [ -f "$VIMRC" ]; then
  rm "$VIMRC"
fi
ln -s "$DOTFILES"/.vimrc "$VIMRC"

if [ "$(uname)" = "Darwin" ]; then
  echo "🍉 Setting up mac"
  # shellcheck source=/dev/null
  . "$DOTFILES"/macos/install.sh
fi

echo "🍉 Setting up codex agents"
# shellcheck source=/dev/null
. "$DOTFILES"/agents/install.sh

echo "🍉 Setting up zsh"
NPC="$HOME/.non_public_commands.sh"
echo "🍉     Setting up non publich commands"
if [ -f "$NPC" ]; then
  rm "$NPC"
fi
ln -s "$DOTFILES"/zsh/.non_public_commands.sh "$NPC"
# shellcheck source=/dev/null
. "$DOTFILES"/zsh/install.sh

echo "🍉 Setting up git"
GITCONFIG="$HOME/.gitconfig"
if [ -f "$GITCONFIG" ]; then
  rm "$GITCONFIG"
fi
ln -s "$DOTFILES"/.gitconfig "$GITCONFIG"
