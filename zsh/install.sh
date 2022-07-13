#!/bin/sh
echo "🍉 Setting up zsh"
ZSH_DIR="$HOME/dotfiles/zsh"

echo "🍉   Setting up oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

echo "🍉   Setting up zshrc"
ZSHRC="$HOME"/.zshrc
rm "$ZSHRC"
ln -s "$ZSH_DIR"/.zshrc "$ZSHRC"

if [ "$(uname)" = "Darwin" ]; then
  echo "  Setting up proxy"
  PROXY_FILE="$HOME/.proxy.zsh"
  rm "$PROXY_FILE"
  ln -s "$ZSH_DIR"/.proxy.zsh "$PROXY_FILE"
fi

echo "🍉   Setting up powerlevel10k"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
P10K_FILE="$HOME"/.p10k.zsh
rm "$P10K_FILE"
ln -s "$ZSH_DIR"/.p10k.zsh "$P10K_FILE"
