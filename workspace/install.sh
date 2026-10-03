#!/bin/sh
# Standalone workspace setup; also called by the main dotfiles installer.
set -eu

WORKSPACE_SOURCE=$(CDPATH='' cd -P "$(dirname "$0")" && pwd)
WORKSPACE_ROOT="$HOME/Workspace"

say() { printf '%s\n' "workspace: $*"; }

# Print absolute path $1 relative to absolute directory $2.
relative_path() {
  rel_base=$2
  rel_up=
  while :; do
    case "$1/" in "$rel_base"/*) break ;; esac
    rel_up="../$rel_up"
    rel_base=${rel_base%/*}
  done
  printf '%s\n' "$rel_up${1#"$rel_base"/}"
}

# Clone or update one listed repository. sync_repos runs several at once.
sync_one() {
  repo=$1
  checkout="$WORKSPACE_ROOT/github.com/$repo"
  if [ ! -e "$checkout" ] && [ ! -L "$checkout" ]; then
    for tool in curl jq; do
      if ! command -v "$tool" >/dev/null 2>&1; then
        say "SKIP $repo: $tool is not installed"
        return 0
      fi
    done
    # Anonymous metadata lookup keeps private repositories out of this public
    # list. Only a first clone needs it; existing checkouts are matched by origin.
    if ! metadata=$(curl -q -fsSL --connect-timeout 10 --max-time 30 \
      "https://api.github.com/repos/$repo") ||
      ! printf '%s' "$metadata" | jq -e --arg repo "$repo" \
        '.private == false and .visibility == "public" and
         (.full_name | ascii_downcase) == ($repo | ascii_downcase)' >/dev/null; then
      say "SKIP $repo: public repository could not be verified"
      return 0
    fi
    say "cloning $repo"
    if GIT_TERMINAL_PROMPT=0 git clone -q "https://github.com/$repo.git" "$checkout"; then
      say "cloned $repo"
    else
      say "SKIP $repo: clone failed"
    fi
    return 0
  fi
  if [ ! -e "$checkout/.git" ]; then
    say "ERROR: $checkout exists but is not a checkout"
    return 1
  fi
  # A checkout without origin falls through to the mismatch error below.
  origin=$(git -C "$checkout" config --get remote.origin.url) || origin=
  case "$origin" in
    https://github.com/*) origin_repo=${origin#https://github.com/} ;;
    git@github.com:*) origin_repo=${origin#git@github.com:} ;;
    ssh://git@github.com/*) origin_repo=${origin#ssh://git@github.com/} ;;
    *) origin_repo= ;;
  esac
  origin_repo=${origin_repo%.git}
  if [ "$(printf '%s' "$origin_repo" | tr '[:upper:]' '[:lower:]')" != \
    "$(printf '%s' "$repo" | tr '[:upper:]' '[:lower:]')" ]; then
    say "ERROR: origin does not match $repo; checkout preserved"
    return 1
  fi
  sh "$WORKSPACE_SOURCE/repos.sh" update "$checkout"
}

sync_repos() {
  if ! command -v git >/dev/null 2>&1; then
    say "SKIP GitHub list: git is not installed"
    return 0
  fi
  repo_errors=0
  repos=
  while IFS= read -r repo_line || [ -n "$repo_line" ]; do
    repo=$(printf '%s\n' "$repo_line" | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -n "$repo" ] || continue
    if ! printf '%s\n' "$repo" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+$' ||
      [ "${repo#*/}" = . ] || [ "${repo#*/}" = .. ]; then
      say "ERROR: invalid GitHub owner/repo: $repo"
      repo_errors=1
      continue
    fi
    repos="$repos$repo
"
  done < "$WORKSPACE_SOURCE/github-repos.txt"
  # Validated names contain no whitespace, so plain xargs splitting is safe.
  if [ -n "$repos" ]; then
    printf '%s' "$repos" | xargs -n 1 -P 4 sh "$0" sync-one || repo_errors=1
  fi
  return "$repo_errors"
}

setup_projectless() (
  for tool in codex jq; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      say "SKIP App storage: $tool is not installed"
      return 0
    fi
  done
  rpc_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-workspace.XXXXXX")
  server_pid=
  # shellcheck disable=SC2329 # Invoked by the exit trap.
  cleanup() {
    if [ -n "$server_pid" ]; then
      kill "$server_pid" 2>/dev/null || :
      wait "$server_pid" 2>/dev/null || :
    fi
    rm -rf "$rpc_dir"
  }
  trap cleanup 0
  trap 'exit 1' 1 2 15
  mkfifo "$rpc_dir/input"
  exec 3<> "$rpc_dir/input"
  # Keep stdin open while using the CLI's native config API. Never edit its database.
  (cd "$HOME" && exec codex app-server) < "$rpc_dir/input" > "$rpc_dir/output" 2> "$rpc_dir/error" &
  server_pid=$!
  rpc_id=0
  request() {
    rpc_id=$((rpc_id + 1))
    jq -nc --argjson id "$rpc_id" --arg method "$1" --argjson params "$2" \
      '{id: $id, method: $method, params: $params}' >&3 || return 1
    attempts=0
    while [ "$attempts" -lt 100 ]; do
      reply=$(jq -c --argjson id "$rpc_id" \
        'select(.id == $id and (has("result") or has("error")))' \
        "$rpc_dir/output" 2>/dev/null) || reply=
      if [ -n "$reply" ]; then
        if printf '%s' "$reply" | jq -e 'has("error")' >/dev/null; then
          say "ERROR: $(printf '%s' "$reply" | jq -r '.error.message')"
          return 1
        fi
        return 0
      fi
      kill -0 "$server_pid" 2>/dev/null || break
      sleep 0.1
      attempts=$((attempts + 1))
    done
    say "ERROR: Codex config API did not answer $1"
    return 1
  }
  request initialize '{"clientInfo":{"name":"dotfiles-workspace","version":"1"}}'
  request config/read '{"includeLayers":false}'
  old_value=$(printf '%s' "$reply" | jq -c '.result.config.desktop.projectlessWorkspaceRoot // null')
  old_root=$(printf '%s' "$old_value" | jq -r '. // empty')
  old_root=${old_root:-"$HOME/Documents/Codex"}
  new_root="$WORKSPACE_ROOT/local/chatgpt"
  case "$old_root" in
    /*) ;;
    *) say "ERROR: App storage path is not absolute"; return 1 ;;
  esac
  if [ -L "$new_root" ] || { [ -e "$new_root" ] && [ ! -d "$new_root" ]; }; then
    say "ERROR: App storage target must be a real directory: $new_root"
    return 1
  fi
  source_root="$old_root"
  if [ -d "$old_root" ]; then
    source_root=$(CDPATH='' cd -P "$old_root" && pwd)
  elif [ -L "$old_root" ] && [ ! -e "$old_root" ]; then
    : # Compatibility link synced from another machine; nothing to migrate here.
  elif [ -e "$old_root" ]; then
    say "ERROR: App storage source is not a readable directory: $old_root"
    return 1
  fi
  target_root="$(CDPATH='' cd -P "$WORKSPACE_ROOT/local" && pwd)/chatgpt"
  if [ "$source_root" != "$target_root" ]; then
    case "$target_root/" in
      "$source_root/"*) say "ERROR: App storage directories overlap"; return 1 ;;
    esac
    case "$source_root/" in
      "$target_root/"*) say "ERROR: App storage directories overlap"; return 1 ;;
    esac
    if [ -d "$source_root" ] && [ -d "$new_root" ] &&
      [ -n "$(find "$new_root" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
      say "ERROR: both App storage directories contain data; nothing moved"
      return 1
    fi
  fi
  write_root() {
    params=$(jq -nc --argjson value "$1" \
      '{keyPath:"desktop.projectlessWorkspaceRoot", value:$value, mergeStrategy:"replace"}')
    request config/value/write "$params"
  }
  new_value=$(printf '%s' "$new_root" | jq -Rs .)
  if [ "$old_value" != "$new_value" ]; then
    write_root "$new_value"
  fi
  request config/read '{"includeLayers":false}'
  if [ "$(printf '%s' "$reply" | jq -r '.result.config.desktop.projectlessWorkspaceRoot')" != "$new_root" ]; then
    say "ERROR: App storage config did not take effect; files preserved"
    return 1
  fi
  # Configuration changes first. Existing files are moved without merging trees.
  if [ "$source_root" != "$target_root" ] && [ -d "$source_root" ]; then
    if { [ ! -d "$new_root" ] || rmdir "$new_root"; } && mv "$source_root" "$new_root"; then
      [ -d "$new_root" ] && [ ! -e "$source_root" ]
      # Relative, so the link still resolves if its directory syncs to another user.
      ln -s "$(relative_path "$target_root" "${source_root%/*}")" "$source_root"
      say "moved App files to $new_root; kept the old path as a compatibility link"
    else
      write_root "$old_value" || say "ERROR: restore the previous App storage setting manually"
      say "ERROR: App file migration failed; inspect $old_root and $new_root"
      return 1
    fi
  else
    mkdir -p "$new_root"
    say "App storage ready: $new_root"
  fi
)

# Internal entry point for the parallel runs started by sync_repos.
if [ "${1:-}" = sync-one ]; then
  sync_one "$2"
  exit
fi

mkdir -p "$WORKSPACE_ROOT/local"
rules="$WORKSPACE_ROOT/AGENTS.md"
if [ -L "$rules" ] && [ "$(readlink "$rules")" = "$WORKSPACE_SOURCE/AGENTS.workspace.md" ]; then
  say "AGENTS.md already linked"
else
  # dotfiles is authoritative for this one managed file; never remove a directory.
  if [ -d "$rules" ] && [ ! -L "$rules" ]; then
    say "ERROR: $rules is a directory"
    exit 1
  fi
  rm -f "$rules"
  ln -s "$WORKSPACE_SOURCE/AGENTS.workspace.md" "$rules"
  say "linked AGENTS.md"
fi
result=0
sync_repos || result=1
setup_projectless
exit "$result"
