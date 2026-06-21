#!/bin/sh
set -u

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"
export PATH

CONFIG_PATH="${AUDIO_ROUTER_CONFIG:-$HOME/.config/audio-router/config.sh}"
if [ -f "$CONFIG_PATH" ]; then
  # shellcheck source=/dev/null
  . "$CONFIG_PATH"
fi

: "${AUDIO_ROUTER_HEADPHONES_OUTPUT:=}"
: "${AUDIO_ROUTER_PREFERRED_INPUT:=}"
: "${AUDIO_ROUTER_FALLBACK_OUTPUT:=}"
: "${AUDIO_ROUTER_FALLBACK_INPUT:=}"
: "${AUDIO_ROUTER_CHECK_INTERVAL_SECONDS:=5}"

SWITCH_AUDIO_SOURCE="$(command -v SwitchAudioSource || true)"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

list_devices() {
  "$SWITCH_AUDIO_SOURCE" -a -t "$1" 2>/dev/null || true
}

device_available() {
  type="$1"
  device="$2"

  [ -n "$device" ] || return 1
  list_devices "$type" | grep -F -x -q "$device"
}

current_device() {
  "$SWITCH_AUDIO_SOURCE" -c -t "$1" 2>/dev/null || true
}

set_device() {
  type="$1"
  device="$2"

  [ -n "$device" ] || return 1
  device_available "$type" "$device" || return 1

  if [ "$(current_device "$type")" = "$device" ]; then
    return 0
  fi

  if "$SWITCH_AUDIO_SOURCE" -t "$type" -s "$device" >/dev/null 2>&1; then
    log "set $type -> $device"
    return 0
  fi

  log "failed to set $type -> $device"
  return 1
}

set_system_output() {
  device="$1"

  [ -n "$device" ] || return 1

  if [ "$(current_device system)" = "$device" ]; then
    return 0
  fi

  if "$SWITCH_AUDIO_SOURCE" -t system -s "$device" >/dev/null 2>&1; then
    log "set system -> $device"
    return 0
  fi

  return 1
}

route_output() {
  output="$AUDIO_ROUTER_FALLBACK_OUTPUT"

  if device_available output "$AUDIO_ROUTER_HEADPHONES_OUTPUT"; then
    output="$AUDIO_ROUTER_HEADPHONES_OUTPUT"
  fi

  if set_device output "$output"; then
    set_system_output "$output" || true
    return 0
  fi

  if [ "$output" != "$AUDIO_ROUTER_FALLBACK_OUTPUT" ]; then
    set_device output "$AUDIO_ROUTER_FALLBACK_OUTPUT" || true
    set_system_output "$AUDIO_ROUTER_FALLBACK_OUTPUT" || true
  fi
}

route_input() {
  if set_device input "$AUDIO_ROUTER_PREFERRED_INPUT"; then
    return 0
  fi

  set_device input "$AUDIO_ROUTER_FALLBACK_INPUT" || true
}

apply_route() {
  if [ -z "$SWITCH_AUDIO_SOURCE" ]; then
    log "SwitchAudioSource is not installed"
    return 127
  fi

  route_output
  route_input
}

case "${1:---loop}" in
  --once)
    apply_route
    ;;
  --loop)
    while :; do
      apply_route
      sleep "$AUDIO_ROUTER_CHECK_INTERVAL_SECONDS"
    done
    ;;
  *)
    printf 'Usage: %s [--once|--loop]\n' "$0" >&2
    exit 64
    ;;
esac
