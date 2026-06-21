#!/bin/sh
# Sets up Zed user-level configuration.

ZED_DOTFILES="$HOME/dotfiles/zed"
ZED_CONFIG_DIR="$HOME/.config/zed"

mkdir -p "$ZED_CONFIG_DIR"

ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"
if [ -e "$ZED_SETTINGS" ] || [ -L "$ZED_SETTINGS" ]; then
  rm "$ZED_SETTINGS"
fi
ln -s "$ZED_DOTFILES/settings.json" "$ZED_SETTINGS"

ZED_KEYMAP="$ZED_CONFIG_DIR/keymap.json"
if [ -e "$ZED_KEYMAP" ] || [ -L "$ZED_KEYMAP" ]; then
  rm "$ZED_KEYMAP"
fi
ln -s "$ZED_DOTFILES/keymap.json" "$ZED_KEYMAP"
