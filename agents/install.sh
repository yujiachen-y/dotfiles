#!/bin/sh
echo "🍉 Setting up codex agents"
AGENTS_DIR="$HOME/dotfiles/agents"
CODEX_DIR="$HOME/.codex"

mkdir -p "$CODEX_DIR"

echo "🍉   Setting up shared agent config"
AGENTS_TARGET="$CODEX_DIR/AGENTS.md"
if [ -e "$AGENTS_TARGET" ] || [ -L "$AGENTS_TARGET" ]; then
  rm -rf "$AGENTS_TARGET"
fi
ln -s "$AGENTS_DIR/AGENTS.shared.md" "$AGENTS_TARGET"

echo "🍉   Setting up prompts"
PROMPTS_TARGET="$CODEX_DIR/prompts"
if [ -e "$PROMPTS_TARGET" ] || [ -L "$PROMPTS_TARGET" ]; then
  rm -rf "$PROMPTS_TARGET"
fi
ln -s "$AGENTS_DIR/prompts" "$PROMPTS_TARGET"

echo "🍉   Setting up skills"
# Old layout symlinked $CODEX_DIR/skills into the repo, so Codex wrote its
# bundled .system skills straight into dotfiles. Drop the stale link only.
if [ -L "$CODEX_DIR/skills" ]; then
  rm -f "$CODEX_DIR/skills"
fi
# Per-skill links into ~/.claude/skills and ~/.agents/skills (Codex).
sh "$AGENTS_DIR/link-skills.sh"

echo "🍉   Setting up claude cli"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

echo "🍉     Setting up CLAUDE.md"
CLAUDE_CONFIG="$CLAUDE_DIR/CLAUDE.md"
if [ -e "$CLAUDE_CONFIG" ] || [ -L "$CLAUDE_CONFIG" ]; then
  rm -rf "$CLAUDE_CONFIG"
fi
ln -s "$AGENTS_DIR/AGENTS.shared.md" "$CLAUDE_CONFIG"

echo "🍉     Setting up claude commands"
CLAUDE_COMMANDS_TARGET="$CLAUDE_DIR/commands"
if [ -e "$CLAUDE_COMMANDS_TARGET" ] || [ -L "$CLAUDE_COMMANDS_TARGET" ]; then
  rm -rf "$CLAUDE_COMMANDS_TARGET"
fi
ln -s "$AGENTS_DIR/prompts" "$CLAUDE_COMMANDS_TARGET"

echo "🍉     Setting up claude statusline"
CLAUDE_STATUSLINE_SOURCE="$AGENTS_DIR/statusline-command.sh"
CLAUDE_STATUSLINE_TARGET="$CLAUDE_DIR/statusline-command.sh"
if [ -e "$CLAUDE_STATUSLINE_TARGET" ] || [ -L "$CLAUDE_STATUSLINE_TARGET" ]; then
  rm -rf "$CLAUDE_STATUSLINE_TARGET"
fi
ln -s "$CLAUDE_STATUSLINE_SOURCE" "$CLAUDE_STATUSLINE_TARGET"

echo "🍉     Updating claude settings"
CLAUDE_SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_SETTINGS_TMP="$CLAUDE_DIR/settings.json.tmp"
CLAUDE_STATUSLINE_COMMAND="bash $CLAUDE_STATUSLINE_TARGET"

if [ ! -f "$CLAUDE_SETTINGS" ]; then
  echo '{}' > "$CLAUDE_SETTINGS"
fi

if command -v jq >/dev/null 2>&1; then
  if jq \
    --arg command "$CLAUDE_STATUSLINE_COMMAND" \
    '.statusLine = ((.statusLine // {}) + {type: "command", command: $command, padding: 0})' \
    "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS_TMP"; then
    mv "$CLAUDE_SETTINGS_TMP" "$CLAUDE_SETTINGS"
  else
    rm -f "$CLAUDE_SETTINGS_TMP"
    echo "⚠️     Failed to update $CLAUDE_SETTINGS, please check JSON format"
  fi
else
  echo "⚠️     jq not found, skipped updating $CLAUDE_SETTINGS"
fi

echo "🍉   Setting up shared agent plugins"
PLUGINS_CONFIG="$AGENTS_DIR/plugins.yaml"
CONFIG_QUERY='
  (kind == "seq") and (
    [.[] | select(
      (.source | tag) != "!!str" or
      (.plugins | kind) != "seq"
    )] | length == 0
  )
'
MARKETPLACE_QUERY='.[].source'
PLUGIN_QUERY='.[].plugins[]'

if ! command -v mise >/dev/null 2>&1; then
  echo "⚠️     mise not found, skipped installing shared agent plugins"
elif ! mise exec -- yq -e "$CONFIG_QUERY" "$PLUGINS_CONFIG" >/dev/null; then
  echo "⚠️     Invalid plugin config: $PLUGINS_CONFIG"
else
  if command -v codex >/dev/null 2>&1; then
    mise exec -- yq -r "$MARKETPLACE_QUERY" "$PLUGINS_CONFIG" |
      xargs -n 1 codex plugin marketplace add
    mise exec -- yq -r "$PLUGIN_QUERY" "$PLUGINS_CONFIG" |
      xargs -n 1 codex plugin add
  else
    echo "⚠️     codex not found, skipped installing codex plugins"
  fi

  if command -v claude >/dev/null 2>&1 &&
    sh -c 'env CLAUDECODE= claude --version >/dev/null 2>&1' 2>/dev/null; then
    mise exec -- yq -r "$MARKETPLACE_QUERY" "$PLUGINS_CONFIG" |
      xargs -n 1 env CLAUDECODE= claude plugin marketplace add --scope user
    mise exec -- yq -r "$PLUGIN_QUERY" "$PLUGINS_CONFIG" |
      xargs -n 1 env CLAUDECODE= claude plugin install --scope user
  else
    echo "⚠️     claude not available, skipped installing claude plugins"
  fi
fi

echo "🍉   Setting up shared agent skills"
SKILLS_CONFIG="$AGENTS_DIR/skills.yaml"
SKILLS_CONFIG_QUERY='
  (kind == "seq") and (
    [.[] | select(
      (.source | tag) != "!!str" or
      (.skills | kind) != "seq"
    )] | length == 0
  )
'
# One "source skill" pair per line; $source is a yq variable.
# shellcheck disable=SC2016
SKILL_PAIR_QUERY='.[] | .source as $source | .skills[] | $source + " " + .'

if ! command -v skills >/dev/null 2>&1; then
  echo "⚠️     skills CLI not found, skipped installing shared agent skills"
elif ! command -v mise >/dev/null 2>&1; then
  echo "⚠️     mise not found, skipped installing shared agent skills"
elif ! mise exec -- yq -e "$SKILLS_CONFIG_QUERY" "$SKILLS_CONFIG" >/dev/null; then
  echo "⚠️     Invalid skill config: $SKILLS_CONFIG"
else
  mise exec -- yq -r "$SKILL_PAIR_QUERY" "$SKILLS_CONFIG" |
    while read -r source skill; do
      # Global install: copy in ~/.agents/skills (Codex), link in ~/.claude/skills.
      if DISABLE_TELEMETRY=1 skills add "$source" -g -y -a claude-code -a codex \
        -s "$skill" </dev/null >/dev/null 2>&1; then
        echo "🍉     $skill from $source"
      else
        echo "⚠️     Failed to install $skill from $source"
      fi
    done
fi
