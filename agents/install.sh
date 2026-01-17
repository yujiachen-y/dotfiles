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

echo "🍉   Setting up gemini cli"
GEMINI_DIR="$HOME/.gemini"

mkdir -p "$GEMINI_DIR"
mkdir -p "$GEMINI_DIR/antigravity"

echo "🍉     Setting up GEMINI.md"
GEMINI_CONFIG="$GEMINI_DIR/GEMINI.md"
if [ -e "$GEMINI_CONFIG" ] || [ -L "$GEMINI_CONFIG" ]; then
  rm -rf "$GEMINI_CONFIG"
fi
ln -s "$AGENTS_DIR/AGENTS.md" "$GEMINI_CONFIG"

ANTIGRAVITY_CONFIG="$GEMINI_DIR/antigravity/GEMINI.md"
if [ -e "$ANTIGRAVITY_CONFIG" ] || [ -L "$ANTIGRAVITY_CONFIG" ]; then
  rm -rf "$ANTIGRAVITY_CONFIG"
fi
ln -s "$AGENTS_DIR/AGENTS.md" "$ANTIGRAVITY_CONFIG"

echo "🍉     Setting up gemini skills"
GEMINI_SKILLS_TARGET="$GEMINI_DIR/skills"
if [ -e "$GEMINI_SKILLS_TARGET" ] || [ -L "$GEMINI_SKILLS_TARGET" ]; then
  rm -rf "$GEMINI_SKILLS_TARGET"
fi
ln -s "$SKILLS_SOURCE" "$GEMINI_SKILLS_TARGET"

ANTIGRAVITY_SKILLS_TARGET="$GEMINI_DIR/antigravity/skills"
if [ -e "$ANTIGRAVITY_SKILLS_TARGET" ] || [ -L "$ANTIGRAVITY_SKILLS_TARGET" ]; then
  rm -rf "$ANTIGRAVITY_SKILLS_TARGET"
fi
ln -s "$SKILLS_SOURCE" "$ANTIGRAVITY_SKILLS_TARGET"
