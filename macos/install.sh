#!/bin/sh
MACOS_FOLDER="$HOME/dotfiles/macos"

echo "🍉     Setting up brew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
brew bundle --file "$MACOS_FOLDER"/Brewfile

echo "🍉     Setting up audio router"
AUDIO_ROUTER_SHARE_DIR="$HOME/.local/share/audio-router"
AUDIO_ROUTER_CONFIG_DIR="$HOME/.config/audio-router"
mkdir -p "$AUDIO_ROUTER_SHARE_DIR"
mkdir -p "$AUDIO_ROUTER_CONFIG_DIR"
install -m 755 "$MACOS_FOLDER/audio-router/audio-router.sh" "$AUDIO_ROUTER_SHARE_DIR/audio-router.sh"
install -m 755 "$MACOS_FOLDER/audio-router/collect-local-config.sh" "$AUDIO_ROUTER_SHARE_DIR/collect-local-config.sh"
install -m 644 "$MACOS_FOLDER/audio-router/config.example.sh" "$AUDIO_ROUTER_CONFIG_DIR/config.example.sh"
AUDIO_ROUTER_CONFIG="$AUDIO_ROUTER_CONFIG_DIR/config.sh"
if [ ! -f "$AUDIO_ROUTER_CONFIG" ]; then
  "$AUDIO_ROUTER_SHARE_DIR/collect-local-config.sh" "$AUDIO_ROUTER_CONFIG" || \
    install -m 644 "$MACOS_FOLDER/audio-router/config.example.sh" "$AUDIO_ROUTER_CONFIG"
fi

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
if [ -f "$AUDIO_ROUTER_CONFIG" ]; then
  # shellcheck source=/dev/null
  . "$AUDIO_ROUTER_CONFIG"
fi
: "${AUDIO_ROUTER_AGENT_LABEL:=local.audio-router}"
mkdir -p "$LAUNCH_AGENTS_DIR"
AUDIO_ROUTER_AGENT="$LAUNCH_AGENTS_DIR/$AUDIO_ROUTER_AGENT_LABEL.plist"
if [ -e "$AUDIO_ROUTER_AGENT" ] || [ -L "$AUDIO_ROUTER_AGENT" ]; then
  launchctl bootout "gui/$(id -u)" "$AUDIO_ROUTER_AGENT" >/dev/null 2>&1 || true
  rm "$AUDIO_ROUTER_AGENT"
fi
cat > "$AUDIO_ROUTER_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$AUDIO_ROUTER_AGENT_LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>mkdir -p "\$HOME/Library/Logs/audio-router"; exec /bin/sh "\$HOME/.local/share/audio-router/audio-router.sh" --loop >> "\$HOME/Library/Logs/audio-router/audio-router.log" 2>&amp;1</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>ThrottleInterval</key>
  <integer>30</integer>
</dict>
</plist>
PLIST
chmod 644 "$AUDIO_ROUTER_AGENT"
launchctl bootstrap "gui/$(id -u)" "$AUDIO_ROUTER_AGENT" >/dev/null 2>&1 || true
launchctl kickstart -k "gui/$(id -u)/$AUDIO_ROUTER_AGENT_LABEL" >/dev/null 2>&1 || true

echo "🍉     Setting up ghostty"
GHOSTTY_DIR="$HOME/.config/ghostty"
mkdir -p "$GHOSTTY_DIR"
GHOSTTY_CONFIG="$GHOSTTY_DIR/config"
if [ -e "$GHOSTTY_CONFIG" ] || [ -L "$GHOSTTY_CONFIG" ]; then
  rm "$GHOSTTY_CONFIG"
fi
ln -s "$MACOS_FOLDER/ghostty/config" "$GHOSTTY_CONFIG"

echo "🍉     Setting up cmux"
CMUX_DIR="$HOME/.config/cmux"
mkdir -p "$CMUX_DIR"
CMUX_CONFIG="$CMUX_DIR/cmux.json"
if [ -e "$CMUX_CONFIG" ] || [ -L "$CMUX_CONFIG" ]; then
  rm "$CMUX_CONFIG"
fi
ln -s "$MACOS_FOLDER/cmux/cmux.json" "$CMUX_CONFIG"

echo "🍉     Setting up system settings"
"$MACOS_FOLDER"/system_settings.sh
