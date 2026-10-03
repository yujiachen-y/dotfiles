#!/bin/sh
# Shared output for the installers. Source it, then:
#
#   run LABEL CMD...   Quiet step: CMD runs in a subshell under `set -e` with its
#                      output in the log. On a terminal a spinner and the last
#                      few output lines show while it runs, then collapse into
#                      one status line; a failure keeps its error lines below.
#   live LABEL CMD...  Output streams to the terminal; for interactive installers.
#   note TEXT          Inside a step: add TEXT to its status line.
#   warn TEXT          Inside a step: same, and mark the step `!`.
#   ui_output          Inside a step: print its output so far.
#   ui_status ok|warn|fail LABEL [DETAIL]   Report a step that ran no command.
#   ui_sub SCRIPT      Run a sub-installer that reports its own steps.
#   ui_end             Exit; the outermost script first prints the summary.
#
# The outermost script opens the log, and nested installers inherit it through
# DOTFILES_LOG, so a sub-installer run on its own still gets a log and summary.
# note and warn print marker lines that run reads back from the log, so they
# also work from child processes.

ui_esc=$(printf '\033')
ui_tty='' ui_green='' ui_yellow='' ui_red='' ui_dim='' ui_bold='' ui_reset=''
# Off a terminal nothing is cut to fit.
ui_cols=1000
if [ -t 1 ]; then
  ui_tty=1
  ui_cols=$(tput cols 2>/dev/null) || ui_cols=80
  if [ -z "${NO_COLOR:-}" ]; then
    ui_green="${ui_esc}[32m" ui_yellow="${ui_esc}[33m" ui_red="${ui_esc}[31m"
    ui_dim="${ui_esc}[2m" ui_bold="${ui_esc}[1m" ui_reset="${ui_esc}[0m"
  fi
fi
ui_spin=
ui_owner=

if [ -z "${DOTFILES_LOG:-}" ]; then
  ui_owner=1
  ui_began=$(date +%s)
  DOTFILES_LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/install-$(date +%Y%m%d-%H%M%S).log"
  export DOTFILES_LOG
  mkdir -p "${DOTFILES_LOG%/*}"
  : >"$DOTFILES_LOG"
  printf '%sdotfiles%s %s· %s%s\n\n' "$ui_bold" "$ui_reset" "$ui_dim" "$(uname -sm)" "$ui_reset"
fi

note() { printf '@@ note %s\n' "$*"; }
warn() { printf '@@ warn %s\n' "$*"; }
ui_output() { tail -n +"$ui_from" "$DOTFILES_LOG"; }

# Makes output lines fit the terminal: keeps the final state of lines redrawn
# with \r, drops colors, markers and blank lines, and cuts each line to $1
# bytes, which never takes more than $1 columns.
ui_clean() {
  awk -v w="$1" '{
    k = split($0, p, "\r"); s = p[k]
    gsub(/\033\[[0-9;?]*[A-Za-z]/, "", s); gsub(/\t/, "  ", s)
    if (s ~ /^ *$/ || s ~ /^@@ /) next
    if (length(s) > w) { s = substr(s, 1, w - 1); sub(/[\200-\377]+$/, "", s); s = s "…" }
    print s
  }'
}

# The last $1 lines of the current step; with $2 set, its error lines instead
# when it has any.
ui_tail() {
  ui_output | ui_clean $((ui_cols - 6)) | awk -v n="$1" -v errors="${2:-}" '
    { all[++a] = $0; t = $0; sub(/^ +/, "", t) }
    errors && tolower(t) ~ /error|fatal|failed|denied|not found/ && !seen[t]++ { err[++e] = t }
    END {
      if (e) { for (i = (e > n ? e - n + 1 : 1); i <= e; i++) print err[i] }
      else { for (i = (a > n ? a - n + 1 : 1); i <= a; i++) print all[i] }
    }'
}

ui_duration() {
  if [ "$1" -ge 60 ]; then
    printf '%dm%02ds' $(($1 / 60)) $(($1 % 60))
  else
    printf '%ds' "$1"
  fi
}

ui_status() {
  case $1 in
    ok) ui_mark="${ui_green}✓" ;;
    warn) ui_mark="${ui_yellow}!" ;;
    *) ui_mark="${ui_red}✗" ;;
  esac
  # Steps under two seconds show no time.
  ui_time=
  [ "${4:-0}" -lt 2 ] || ui_time=$(ui_duration "$4")
  ui_text=$(printf '%s\n' "${3:-}" | ui_clean $((ui_cols - 28)))
  printf ' %s%s %-16s %s%5s%s  %s\n' "$ui_mark" "$ui_reset" "$2" \
    "$ui_dim" "$ui_time" "$ui_reset" "$ui_text"
  printf '@@ end %s %s\n' "$1" "$2" >>"$DOTFILES_LOG"
}

ui_start() {
  ui_label=$1
  printf '@@ step %s\n' "$1" >>"$DOTFILES_LOG"
  ui_from=$(($(wc -l <"$DOTFILES_LOG") + 1))
  ui_t0=$(date +%s)
}

ui_finish() {
  ui_secs=$(($(date +%s) - ui_t0))
  ui_detail=$(awk -v from="$ui_from" 'NR >= from && /^@@ (note|warn) / {
    printf "%s%s", (n++ ? " · " : ""), substr($0, 9) }' "$DOTFILES_LOG")
  if [ "$1" -ne 0 ]; then
    ui_status fail "$ui_label" "$ui_detail" "$ui_secs"
    ui_tail 5 errors | sed "s/^/   ${ui_dim}│${ui_reset} /"
  elif ui_output | grep -q '^@@ warn '; then
    ui_status warn "$ui_label" "$ui_detail" "$ui_secs"
  else
    ui_status ok "$ui_label" "$ui_detail" "$ui_secs"
  fi
}

# Redraws the spinner line and, below it, the step's last few output lines.
ui_draw() {
  ui_lines=$(ui_tail 5)
  # $(...) drops the final newline, leaving the cursor on the last line drawn.
  ui_frame=$(
    printf '\r%s[J %s%s%s %s\n' "$ui_esc" "$ui_dim" "$1" "$ui_reset" "$ui_label"
    [ -z "$ui_lines" ] ||
      printf '%s\n' "$ui_lines" | sed "s/^/   ${ui_dim}│ /; s/\$/${ui_reset}/"
  )
  ui_up=
  [ "$ui_drawn" -eq 0 ] || ui_up="${ui_esc}[${ui_drawn}A"
  # Line wrap stays off while drawing, so the window is exactly ui_drawn lines.
  printf '%s%s[?7l%s%s[?7h' "$ui_up" "$ui_esc" "$ui_frame" "$ui_esc"
  ui_drawn=0
  [ -z "$ui_lines" ] || ui_drawn=$(($(printf '%s\n' "$ui_lines" | wc -l)))
  # A password prompt is about to print here; stop drawing over it.
  case $(printf '%s\n' "$ui_lines" | tail -n 1) in
    *[Pp]assword*) ui_frozen=1; printf '\n' ;;
  esac
}

ui_erase() {
  [ -z "$ui_frozen" ] || return 0
  [ "$ui_drawn" -eq 0 ] || printf '%s[%dA' "$ui_esc" "$ui_drawn"
  printf '\r%s[J' "$ui_esc"
}

# The drawing loop ends when ui_spin_stop removes the flag file, or when this
# script dies, and erases what it drew either way.
ui_spin_start() {
  [ -n "$ui_tty" ] || return 0
  ui_flag="$DOTFILES_LOG.running"
  : >"$ui_flag"
  (
    ui_drawn=0 ui_frozen=
    while :; do
      for ui_frame_char in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏; do
        if [ ! -e "$ui_flag" ] || ! kill -0 "$$" 2>/dev/null; then
          ui_erase
          rm -f "$ui_flag"
          exit 0
        fi
        [ -n "$ui_frozen" ] || ui_draw "$ui_frame_char"
        sleep 0.1
      done
    done
  ) &
  ui_spin=$!
}

ui_spin_stop() {
  [ -n "$ui_spin" ] || return 0
  rm -f "$ui_flag"
  wait "$ui_spin" 2>/dev/null || :
  ui_spin=
}

run() {
  ui_start "$1"
  shift
  ui_spin_start
  # set -e is ignored inside any `if`, `&&` or `||`, so the step runs as a
  # plain command with the caller's errexit paused around it.
  case $- in *e*) ui_errexit=1; set +e ;; *) ui_errexit= ;; esac
  (set -e; "$@") </dev/null >>"$DOTFILES_LOG" 2>&1
  ui_rc=$?
  [ -z "$ui_errexit" ] || set -e
  ui_spin_stop
  ui_finish "$ui_rc"
}

live() {
  ui_start "$1"
  shift
  printf ' %s▸ %s%s\n' "$ui_dim" "$ui_label" "$ui_reset"
  if "$@"; then ui_rc=0; else ui_rc=$?; fi
  ui_finish "$ui_rc"
}

# A sub-installer reports its own steps; flag it only if it stops early.
ui_sub() {
  sh "$1" || {
    ui_rc=$?
    ui_sub_dir=${1%/*}
    ui_status fail "${ui_sub_dir##*/}" "stopped early (exit $ui_rc)"
  }
}

ui_end() {
  [ -n "$ui_owner" ] || exit 0
  ui_fails=$(grep -c '^@@ end fail ' "$DOTFILES_LOG") || :
  ui_warns=$(grep -c '^@@ end warn ' "$DOTFILES_LOG") || :
  ui_summary="Done in $(ui_duration $(($(date +%s) - ui_began)))"
  [ "$ui_fails" -eq 0 ] || ui_summary="$ui_summary · $ui_red$ui_fails failed$ui_reset$ui_bold"
  ui_plural=
  [ "$ui_warns" -le 1 ] || ui_plural=s
  [ "$ui_warns" -eq 0 ] ||
    ui_summary="$ui_summary · $ui_yellow$ui_warns warning$ui_plural$ui_reset$ui_bold"
  printf '\n %s%s%s\n %sLog: %s%s\n' "$ui_bold" "$ui_summary" "$ui_reset" \
    "$ui_dim" "$DOTFILES_LOG" "$ui_reset"
  [ "$ui_fails" -eq 0 ] || exit 1
  exit 0
}
