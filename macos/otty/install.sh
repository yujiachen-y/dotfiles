#!/bin/sh
# Sets up Otty terminal configuration.
#
# Unlike Ghostty, Otty rewrites config.toml itself whenever a setting is
# changed from the GUI, and it does so by writing a temp file and renaming it
# over the target. That replaces a symlinked config.toml with a regular file,
# which silently detaches it from this repo. So we link the whole config
# directory instead: the rename happens *inside* the directory, leaving the
# directory symlink intact and the tracked config.toml as the real file.

OTTY_DOTFILES="$HOME/dotfiles/macos/otty"
OTTY_CONFIG_DIR="$HOME/.config/otty"

mkdir -p "$HOME/.config"

if [ -L "$OTTY_CONFIG_DIR" ]; then
  rm "$OTTY_CONFIG_DIR"
elif [ -d "$OTTY_CONFIG_DIR" ]; then
  # A real directory from a fresh Otty install. Keep any local config.toml
  # that is not tracked yet, then move the directory aside rather than
  # deleting it, so app-seeded themes are never lost silently.
  if [ -f "$OTTY_CONFIG_DIR/config.toml" ] && [ ! -f "$OTTY_DOTFILES/config.toml" ]; then
    cp "$OTTY_CONFIG_DIR/config.toml" "$OTTY_DOTFILES/config.toml"
  fi
  mv "$OTTY_CONFIG_DIR" "$OTTY_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
elif [ -e "$OTTY_CONFIG_DIR" ]; then
  rm "$OTTY_CONFIG_DIR"
fi

ln -s "$OTTY_DOTFILES" "$OTTY_CONFIG_DIR"
