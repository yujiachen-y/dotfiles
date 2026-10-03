#!/bin/sh
MACOS_FOLDER="$HOME/dotfiles/macos"
# shellcheck source=/dev/null
. "$HOME"/dotfiles/scripts/ui.sh

update_brew() {
  if ! brew update; then
    warn "update failed, used the cached index"
  fi
}

# --verbose keeps the rolling output window busy during long downloads.
bundle_brew() {
  brew bundle --verbose --file "$MACOS_FOLDER"/Brewfile
  ui_output | sed -nE 's/^Installing ([^ ]+)$/installed \1/p; s/^Upgrading ([^ ]+)$/upgraded \1/p' |
    while IFS= read -r change; do note "$change"; done
}

if ! command -v brew >/dev/null 2>&1; then
  live homebrew /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
run "brew update" update_brew
run "brew bundle" bundle_brew
run otty sh "$MACOS_FOLDER"/otty/install.sh
run zed sh "$MACOS_FOLDER"/zed/install.sh
run "macOS defaults" "$MACOS_FOLDER"/system_settings.sh
ui_end
