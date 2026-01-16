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

echo "🍉   Setting up skills"
SKILLS_SOURCE="$AGENTS_DIR/skills"
SKILLS_TARGET="$CODEX_DIR/skills"
SYSTEM_SOURCE="$CODEX_DIR/skills.system"
SYSTEM_LINK="$SKILLS_SOURCE/.system"

mkdir -p "$SKILLS_SOURCE"

if [ -d "$SKILLS_TARGET" ] && [ ! -L "$SKILLS_TARGET" ]; then
  if [ -d "$SKILLS_TARGET/.system" ] && [ ! -e "$SYSTEM_SOURCE" ]; then
    mv "$SKILLS_TARGET/.system" "$SYSTEM_SOURCE"
  fi
fi

if [ -e "$SYSTEM_SOURCE" ]; then
  if [ -e "$SYSTEM_LINK" ] || [ -L "$SYSTEM_LINK" ]; then
    rm -rf "$SYSTEM_LINK"
  fi
  ln -s "$SYSTEM_SOURCE" "$SYSTEM_LINK"
fi

if [ -e "$SKILLS_TARGET" ] || [ -L "$SKILLS_TARGET" ]; then
  rm -rf "$SKILLS_TARGET"
fi
ln -s "$SKILLS_SOURCE" "$SKILLS_TARGET"
