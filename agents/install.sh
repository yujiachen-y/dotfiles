#!/bin/sh
echo "🍉 Setting up codex agents"
AGENTS_DIR="$HOME/dotfiles/agents"
CODEX_DIR="$HOME/.codex"

mkdir -p "$CODEX_DIR"

echo "🍉   Setting up AGENTS.md"
AGENTS_TARGET="$CODEX_DIR/AGENTS.md"
if [ -e "$AGENTS_TARGET" ] || [ -L "$AGENTS_TARGET" ]; then
  rm -rf "$AGENTS_TARGET"
fi
ln -s "$AGENTS_DIR/AGENTS.md" "$AGENTS_TARGET"

echo "🍉   Setting up prompts"
PROMPTS_TARGET="$CODEX_DIR/prompts"
if [ -e "$PROMPTS_TARGET" ] || [ -L "$PROMPTS_TARGET" ]; then
  rm -rf "$PROMPTS_TARGET"
fi
ln -s "$AGENTS_DIR/prompts" "$PROMPTS_TARGET"
