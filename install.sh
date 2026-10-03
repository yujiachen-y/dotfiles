#!/bin/sh
DOTFILES="$HOME/dotfiles"
# shellcheck source=/dev/null
. "$DOTFILES"/scripts/ui.sh

link_vim() {
  VIMRC="$HOME/.vimrc"
  if [ -f "$VIMRC" ]; then
    rm "$VIMRC"
  fi
  ln -s "$DOTFILES"/.vimrc "$VIMRC"
}

link_non_public_commands() {
  NPC="$HOME/.non_public_commands.sh"
  if [ -f "$NPC" ]; then
    rm "$NPC"
  fi
  ln -s "$DOTFILES"/zsh/.non_public_commands.sh "$NPC"
}

include_gitconfig() {
  GITCONFIG="$HOME/.gitconfig"
  TRACKED_GITCONFIG="$DOTFILES/.gitconfig"
  if [ -L "$GITCONFIG" ]; then
    rm "$GITCONFIG"
  fi
  if [ ! -e "$GITCONFIG" ]; then
    touch "$GITCONFIG"
  fi
  if ! git config --file "$GITCONFIG" --get-all include.path |
    grep -Fqx "$TRACKED_GITCONFIG"; then
    git config --file "$GITCONFIG" --add include.path "$TRACKED_GITCONFIG"
  fi
}

run vim link_vim
if [ "$(uname)" = "Darwin" ]; then
  ui_sub "$DOTFILES"/macos/install.sh
fi
ui_sub "$DOTFILES"/mise/install.sh
ui_sub "$DOTFILES"/agents/install.sh
run "private commands" link_non_public_commands
ui_sub "$DOTFILES"/zsh/install.sh
run git include_gitconfig
ui_sub "$DOTFILES"/workspace/install.sh
ui_end
