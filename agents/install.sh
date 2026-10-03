#!/bin/sh
AGENTS_DIR="$HOME/dotfiles/agents"
CODEX_DIR="$HOME/.codex"
CLAUDE_DIR="$HOME/.claude"
# shellcheck source=/dev/null
. "$HOME"/dotfiles/scripts/ui.sh

# Replace $2 with a link to $1.
relink() {
  if [ -e "$2" ] || [ -L "$2" ]; then
    rm -rf "$2"
  fi
  ln -s "$1" "$2"
}

link_agents() {
  mkdir -p "$CODEX_DIR" "$CLAUDE_DIR"
  relink "$AGENTS_DIR/AGENTS.shared.md" "$CODEX_DIR/AGENTS.md"
  relink "$AGENTS_DIR/prompts" "$CODEX_DIR/prompts"
  # Old layout symlinked $CODEX_DIR/skills into the repo, so Codex wrote its
  # bundled .system skills straight into dotfiles. Drop the stale link only.
  if [ -L "$CODEX_DIR/skills" ]; then
    rm -f "$CODEX_DIR/skills"
  fi
  # Per-skill links into ~/.claude/skills and ~/.agents/skills (Codex).
  sh "$AGENTS_DIR/link-skills.sh"
  relink "$AGENTS_DIR/AGENTS.shared.md" "$CLAUDE_DIR/CLAUDE.md"
  relink "$AGENTS_DIR/prompts" "$CLAUDE_DIR/commands"
  relink "$AGENTS_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
}

update_claude_settings() {
  CLAUDE_SETTINGS="$CLAUDE_DIR/settings.json"
  CLAUDE_SETTINGS_TMP="$CLAUDE_DIR/settings.json.tmp"
  CLAUDE_STATUSLINE_COMMAND="bash $CLAUDE_DIR/statusline-command.sh"

  if [ ! -f "$CLAUDE_SETTINGS" ]; then
    echo '{}' > "$CLAUDE_SETTINGS"
  fi

  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found, skipped"
    return 0
  fi
  if jq \
    --arg command "$CLAUDE_STATUSLINE_COMMAND" \
    '.statusLine = ((.statusLine // {}) + {type: "command", command: $command, padding: 0})' \
    "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS_TMP"; then
    mv "$CLAUDE_SETTINGS_TMP" "$CLAUDE_SETTINGS"
  else
    rm -f "$CLAUDE_SETTINGS_TMP"
    note "could not update $CLAUDE_SETTINGS, check its JSON"
    return 1
  fi
}

PLUGINS_CONFIG="$AGENTS_DIR/plugins.yaml"
CONFIG_QUERY='
  (kind == "seq") and (
    [.[] | select(
      (.source | tag) != "!!str" or
      (.plugins | kind) != "seq"
    )] | length == 0
  )
'

# Sets $marketplaces and $plugins from plugins.yaml.
load_plugins() {
  if ! mise exec -- yq -e "$CONFIG_QUERY" "$PLUGINS_CONFIG" >/dev/null; then
    echo "Invalid plugin config: $PLUGINS_CONFIG"
    return 1
  fi
  marketplaces=$(mise exec -- yq -r '.[].source' "$PLUGINS_CONFIG")
  plugins=$(mise exec -- yq -r '.[].plugins[]' "$PLUGINS_CONFIG")
}

# Fails the step, naming what failed, when $1 lists anything.
report_failed() {
  if [ -n "$1" ]; then
    note "failed:$1"
    return 1
  fi
}

install_codex_plugins() {
  if ! command -v codex >/dev/null 2>&1; then
    warn "codex not found, skipped"
    return 0
  fi
  load_plugins
  failed=
  for source in $marketplaces; do
    codex plugin marketplace add "$source" || failed="$failed ${source##*/}"
  done
  for plugin in $plugins; do
    codex plugin add "$plugin" || failed="$failed ${plugin%@*}"
  done
  report_failed "$failed"
}

install_claude_plugins() {
  if ! command -v claude >/dev/null 2>&1 ||
    ! sh -c 'env CLAUDECODE= claude --version >/dev/null 2>&1' 2>/dev/null; then
    warn "claude not available, skipped"
    return 0
  fi
  load_plugins
  failed=
  for source in $marketplaces; do
    env CLAUDECODE= claude plugin marketplace add --scope user "$source" ||
      failed="$failed ${source##*/}"
  done
  for plugin in $plugins; do
    if ! env CLAUDECODE= claude plugin install --scope user "$plugin"; then
      failed="$failed ${plugin%@*}"
      continue
    fi
    # No -y: a plugin whose install command changed fails here until a person
    # approves it with `claude plugin update`.
    if ! result=$(env CLAUDECODE= claude plugin update --scope user --json "$plugin"); then
      failed="$failed ${plugin%@*}"
    fi
    printf '%s\n' "$result"
    version=$(printf '%s' "$result" | jq -r 'select(.updateOutcome == "updated") |
      "\(.oldVersion) → \(.newVersion)"' 2>/dev/null) || version=
    if [ -n "$version" ]; then
      note "updated ${plugin%@*} $version"
    fi
  done
  report_failed "$failed"
}

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

install_skills() {
  if ! command -v skills >/dev/null 2>&1; then
    warn "skills CLI not found, skipped"
    return 0
  fi
  if ! mise exec -- yq -e "$SKILLS_CONFIG_QUERY" "$SKILLS_CONFIG" >/dev/null; then
    echo "Invalid skill config: $SKILLS_CONFIG"
    return 1
  fi
  pairs=$(mise exec -- yq -r "$SKILL_PAIR_QUERY" "$SKILLS_CONFIG")
  failed=
  while read -r source skill; do
    [ -n "$source" ] || continue
    # Global install: copy in ~/.agents/skills (Codex), link in ~/.claude/skills.
    DISABLE_TELEMETRY=1 skills add "$source" -g -y -a claude-code -a codex \
      -s "$skill" </dev/null || failed="$failed $skill"
  done <<EOF
$pairs
EOF
  report_failed "$failed"
}

run "agent links" link_agents
run "claude settings" update_claude_settings
if command -v mise >/dev/null 2>&1; then
  run "codex plugins" install_codex_plugins
  run "claude plugins" install_claude_plugins
  run "agent skills" install_skills
else
  ui_status warn "agent plugins" "mise not found, skipped plugins and skills"
fi
ui_end
