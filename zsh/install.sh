#!/bin/sh
ZSH_DIR="$HOME/dotfiles/zsh"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
# shellcheck source=/dev/null
. "$HOME"/dotfiles/scripts/ui.sh

setup_oh_my_zsh() {
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
  git -C "$HOME/.oh-my-zsh" pull --quiet
}

setup_p10k() {
  if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  elif [ -d "$P10K_DIR/.git" ]; then
    git -C "$P10K_DIR" pull --quiet --ff-only
  fi
}

link_zsh() {
  rm -f "$HOME"/.zshrc "$HOME"/.p10k.zsh
  ln -s "$ZSH_DIR"/.zshrc "$HOME"/.zshrc
  ln -s "$ZSH_DIR"/.p10k.zsh "$HOME"/.p10k.zsh
}

run oh-my-zsh setup_oh_my_zsh
run powerlevel10k setup_p10k
run "zsh links" link_zsh
ui_end
