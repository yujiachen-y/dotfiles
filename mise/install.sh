#!/bin/sh
# Sets up mise configuration and installs declared tools.
# mise itself is installed via macos/Brewfile (or OS-specific method).
MISE_DOTFILES="$HOME/dotfiles/mise"
MISE_CONFIG_DIR="$HOME/.config/mise"
# shellcheck source=/dev/null
. "$HOME"/dotfiles/scripts/ui.sh

setup_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not found, skipped (brew bundle installs it)"
    return 0
  fi

  mkdir -p "$MISE_CONFIG_DIR"

  MISE_CONFIG="$MISE_CONFIG_DIR/config.toml"
  if [ -e "$MISE_CONFIG" ] || [ -L "$MISE_CONFIG" ]; then
    rm "$MISE_CONFIG"
  fi
  ln -s "$MISE_DOTFILES/config.toml" "$MISE_CONFIG"

  # mise resolves core tools (node) before npm-backend tools in a single pass,
  # so this works on a fresh machine without nvm/node pre-installed.
  mise install
}

# `latest` resolves once at install time, so `mise install` never moves an
# installed tool forward. Upgrade only the backend-prefixed CLI tools; runtimes
# (node, python, go, ...) stay put because a silent major bump can break
# projects. Exact pins (kitex, golangci-lint, oh-my-pi) are kept by mise upgrade.
upgrade_cli_tools() {
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not found, skipped"
    return 0
  fi
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found, skipped (brew bundle installs it)"
    return 0
  fi

  tools=$(mise ls --current --json |
    jq -r 'keys[] | select(test("^(npm|pipx|go|github):"))')
  # shellcheck disable=SC2086  # one argument per tool
  mise upgrade $tools
}

run mise setup_mise
run "mise upgrade" upgrade_cli_tools
ui_end
