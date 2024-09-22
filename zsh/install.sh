#!/bin/sh
echo "🍉 Setting up zsh"
ZSH_DIR="$HOME/dotfiles/zsh"

echo "🍉   Setting up oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  REPO=${REPO:-ohmyzsh/ohmyzsh}
  REMOTE=${REMOTE:-https://github.com/${REPO}.git}
  BRANCH=${BRANCH:-master}
  git init --quiet "$HOME/.oh-my-zsh" && cd "$HOME/.oh-my-zsh" \
  && git config core.eol lf \
  && git config core.autocrlf false \
  && git config fsck.zeroPaddedFilemode ignore \
  && git config fetch.fsck.zeroPaddedFilemode ignore \
  && git config receive.fsck.zeroPaddedFilemode ignore \
  && git config oh-my-zsh.remote origin \
  && git config oh-my-zsh.branch "$BRANCH" \
  && git remote add origin "$REMOTE" \
  && git fetch --depth=1 origin \
  && git checkout -b "$BRANCH" "origin/$BRANCH"
fi

echo "🍉   Setting up zshrc"
ZSHRC="$HOME"/.zshrc
rm "$ZSHRC"
ln -s "$ZSH_DIR"/.zshrc "$ZSHRC"
