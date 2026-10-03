#!/bin/sh
# Day-to-day checkout management for ~/Workspace; also used by install.sh.
set -eu

ROOT="$HOME/Workspace"

say() { printf '%s\n' "workspace: $*"; }

usage() {
  cat >&2 <<'EOF'
usage: repos.sh pull            fetch every checkout under ~/Workspace and fast-forward the clean ones
       repos.sh add <repo>      clone into ~/Workspace/<host>/<path>
                                <repo> is owner/repo (GitHub over SSH), host/group/repo, or any git URL
EOF
  exit 2
}

# Never wait on a prompt: runs are parallel and may be unattended.
quiet_git() {
  ssh_command=$(git -C "$1" config --get core.sshCommand 2>/dev/null) || ssh_command=ssh
  shift
  GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-$ssh_command -o BatchMode=yes}" git "$@"
}

# Fetch origin and fast-forward when that cannot lose anything. A network failure
# is a skip, not an error; local state is never rewritten.
update() {
  checkout=$1
  name=${checkout#"$ROOT/"}
  if ! git -C "$checkout" config --get remote.origin.url >/dev/null; then
    say "skipped $name (no origin)"
    return 0
  fi
  if ! quiet_git "$checkout" -C "$checkout" fetch -q origin; then
    say "SKIP $name: fetch failed"
    return 0
  fi
  if ! changes=$(git -C "$checkout" status --porcelain); then
    say "ERROR: cannot read status of $name; checkout preserved"
    return 1
  fi
  if [ -n "$changes" ] || ! git -C "$checkout" symbolic-ref -q HEAD >/dev/null; then
    say "fetched $name; kept modified or detached checkout"
    return 0
  fi
  upstream=$(git -C "$checkout" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || upstream=
  case "$upstream" in
    origin/*) ;;
    *) say "fetched $name; no origin upstream for the current branch"; return 0 ;;
  esac
  if git -C "$checkout" merge-base --is-ancestor "$upstream" HEAD; then
    say "current $name"
    return 0
  fi
  if ! git -C "$checkout" merge-base --is-ancestor HEAD "$upstream"; then
    say "fetched $name; kept local commits (fast-forward unavailable)"
    return 0
  fi
  if git -C "$checkout" merge -q --ff-only --no-progress "$upstream"; then
    say "updated $name"
  else
    say "ERROR: fast-forward failed for $name"
    return 1
  fi
}

pull() {
  # Top-level checkouts only; links such as drive/* are not followed.
  find "$ROOT" -maxdepth 6 \( -name node_modules -o -name .pnpm-store \) -prune -o \
    -type d -exec test -e '{}/.git' \; -print -prune |
    tr '\n' '\0' | xargs -0 -n 1 -P 8 sh "$0" update || return 1
}

add() {
  spec=${1%/}
  case "$spec" in
    *://*) url=$spec; path=${spec#*://}; path=${path#*@} ;;
    *@*:*) url=$spec; path=${spec#*@}; path=$(printf '%s' "$path" | sed 's|:|/|') ;;
    *.*/*/*) url="git@${spec%%/*}:${spec#*/}.git"; path=$spec ;;
    */*) url="git@github.com:$spec.git"; path="github.com/$spec" ;;
    *) usage ;;
  esac
  # host:port/path -> host/path; keep every group segment, drop only a trailing .git.
  path=$(printf '%s' "$path" | sed -E 's|^([^/:]+):[0-9]+/|\1/|')
  path=${path%.git}
  path=${path%/}
  case "/$path/" in
    */../*|*/./*|*//*) say "ERROR: cannot derive a path from $spec"; return 1 ;;
  esac
  case "$path" in
    */*/*) ;;
    *) say "ERROR: expected <host>/<owner>/<repo>, got $path"; return 1 ;;
  esac
  target="$ROOT/$path"
  if [ -e "$target/.git" ]; then
    say "already cloned: $target"
    update "$target"
    return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    say "ERROR: $target exists but is not a checkout"
    return 1
  fi
  mkdir -p "$ROOT"
  if quiet_git "$ROOT" clone "$url" "$target"; then
    say "cloned $path"
    printf '%s\n' "$target"
  else
    # git leaves the parent directories it created; drop them if they stayed empty.
    (cd "$ROOT" && rmdir -p "$(dirname "$path")" 2>/dev/null) || :
    say "ERROR: clone failed for $url"
    return 1
  fi
}

[ $# -ge 1 ] || usage
command=$1
shift
case "$command" in
  pull) [ $# -eq 0 ] || usage; pull ;;
  add) [ $# -eq 1 ] || usage; add "$1" ;;
  update) [ $# -eq 1 ] || usage; update "$1" ;;
  *) usage ;;
esac
