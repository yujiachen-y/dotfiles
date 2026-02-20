#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Claude Code custom status line

input=$(cat)

# ── ANSI color helpers ────────────────────────────────────────────────────────
reset="\033[0m"
dim="\033[2m"

red="\033[0;31m";     green="\033[0;32m"
yellow="\033[0;33m";  blue="\033[0;34m";    magenta="\033[0;35m"
cyan="\033[0;36m"

bred="\033[1;31m";    bgreen="\033[1;32m";  byellow="\033[1;33m"
bblue="\033[1;34m";   bmagenta="\033[1;35m";bcyan="\033[1;36m"
bwhite="\033[1;37m"

# ── Read JSON fields (single jq call) ───────────────────────────────────────
eval "$(echo "$input" | jq -r '
  @sh "model_name=\(.model.display_name // "Unknown")",
  @sh "cwd=\(.cwd // .workspace.current_dir // "?")",
  @sh "session_id=\(.session_id // "")",
  @sh "agent_name=\(.agent.name // "")",
  @sh "output_style=\(.output_style.name // "")",
  @sh "ctx_remaining=\(.context_window.remaining_percentage // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // "")",
  @sh "cost_usd=\(.cost.total_cost_usd // "")",
  @sh "total_input=\(.context_window.total_input_tokens // "")",
  @sh "total_output=\(.context_window.total_output_tokens // "")",
  @sh "cache_read=\(.context_window.current_usage.cache_read_input_tokens // "")"
' 2>/dev/null)"

# ── Terminal width (use parent process TTY like ccstatusline) ────────────────
cols=0
# Method 1: find parent process's TTY and query its size
if (( cols == 0 )); then
  parent_tty=$(ps -o tty= -p $(ps -o ppid= -p $$) 2>/dev/null | tr -d ' ')
  if [ -n "$parent_tty" ] && [ "$parent_tty" != "??" ] && [ "$parent_tty" != "?" ]; then
    cols=$(stty size <"/dev/$parent_tty" 2>/dev/null | awk '{print $2}')
  fi
fi
# Method 2: COLUMNS env var
if (( cols == 0 )) && [ -n "${COLUMNS:-}" ]; then cols="$COLUMNS"; fi
# Method 3: tput
if (( cols == 0 )); then cols=$(tput cols 2>/dev/null || echo 0); fi
# Fallback
if (( cols == 0 )); then cols=120; fi
# Subtract padding (Claude Code UI border/padding)
(( cols -= 6 ))

# ── Helpers ──────────────────────────────────────────────────────────────────
sep="${dim} │ ${reset}"

visible_len() {
  local stripped
  stripped=$(echo -e "$1" | sed $'s/\033\[[0-9;]*m//g')
  echo ${#stripped}
}

build_ctx_bar() {
  local pct="$1" w=10
  if [ -z "$pct" ]; then echo -n "${dim}[ctx: --]${reset}"; return; fi

  local filled=$(( (pct * w + 50) / 100 ))
  (( filled > w )) && filled=$w
  (( filled < 0 )) && filled=0
  local empty=$(( w - filled ))

  local c
  if   (( pct >= 50 )); then c="$bgreen"
  elif (( pct >= 20 )); then c="$byellow"
  else                       c="$bred"
  fi

  local bf="" be=""
  for (( i=0; i<filled; i++ )); do bf+="█"; done
  for (( i=0; i<empty;  i++ )); do be+="░"; done

  local blink="" unblink=""
  if (( pct <= 10 )); then blink="\033[5m"; unblink="\033[25m"; fi

  echo -n "${dim}[${reset}${blink}${c}${bf}${unblink}${dim}${be} ${pct}%]${reset}"
}

format_duration() {
  local ms="$1"
  if [ -z "$ms" ] || [ "$ms" = "0" ]; then echo -n "${dim}0s${reset}"; return; fi
  local total_s=$(( ms / 1000 ))
  local h=$(( total_s / 3600 ))
  local m=$(( (total_s % 3600) / 60 ))
  local s=$(( total_s % 60 ))
  if (( h > 0 )); then   echo -n "${bcyan}${h}h${m}m${s}s${reset}"
  elif (( m > 0 )); then echo -n "${bcyan}${m}m${s}s${reset}"
  else                    echo -n "${bcyan}${s}s${reset}"
  fi
}

format_cost() {
  local usd="$1"
  if [ -z "$usd" ] || [ "$usd" = "0" ]; then echo -n "${dim}\$0.00${reset}"; return; fi
  local formatted
  formatted=$(printf '%.2f' "$usd" 2>/dev/null || echo "$usd")
  echo -n "${byellow}\$${formatted}${reset}"
}

format_tokens() {
  local n="$1" color="$2"
  if [ -z "$n" ] || [ "$n" = "0" ] || [ "$n" = "null" ]; then
    echo -n "${dim}0${reset}"; return
  fi
  if (( n >= 1000000 )); then
    local m=$(( n / 1000000 )) r=$(( (n % 1000000) / 100000 ))
    echo -n "${color}${m}.${r}M${reset}"
  elif (( n >= 100000 )); then
    local k=$(( n / 1000 ))
    echo -n "${color}${k}k${reset}"
  elif (( n >= 1000 )); then
    local k=$(( n / 1000 )) r=$(( (n % 1000) / 100 ))
    echo -n "${color}${k}.${r}k${reset}"
  else
    echo -n "${color}${n}${reset}"
  fi
}

model_color() {
  case "$1" in
    *Opus*)   echo -n "$bmagenta" ;;
    *Sonnet*) echo -n "$bcyan"    ;;
    *Haiku*)  echo -n "$bgreen"   ;;
    *)        echo -n "$bwhite"   ;;
  esac
}

# ── Network connectivity (async, cached 10s) ────────────────────────────────
net_cache="/tmp/.claude-net-status"

# Resolve API host from ANTHROPIC_BASE_URL or fall back to api.anthropic.com
api_host="api.anthropic.com"
api_port=443
if [ -n "${ANTHROPIC_BASE_URL:-}" ]; then
  # Extract host and port from URL like https://host:port/path
  _host=$(echo "$ANTHROPIC_BASE_URL" | sed -E 's|^https?://||;s|/.*||;s|:.*||')
  _port=$(echo "$ANTHROPIC_BASE_URL" | sed -nE 's|^https?://[^:/]+:([0-9]+).*|\1|p')
  [ -n "$_host" ] && api_host="$_host"
  [ -n "$_port" ] && api_port="$_port"
fi

check_network() {
  local now
  now=$(date +%s)

  # Read cached result if fresh (< 10s old)
  if [ -f "$net_cache" ]; then
    local mtime
    mtime=$(stat -f %m "$net_cache" 2>/dev/null || echo 0)
    local age=$(( now - mtime ))
    if (( age < 10 )); then
      cat "$net_cache"
      return
    fi
  fi

  # Spawn background check against configured API endpoint
  (nc -z -w2 "$api_host" "$api_port" 2>/dev/null && echo "1" || echo "0") > "$net_cache" &

  # Return last known result, or "1" (assume connected) if no cache yet
  if [ -f "$net_cache" ]; then
    cat "$net_cache"
  else
    echo "1"
  fi
}

net_badge() {
  local status
  status=$(check_network)
  if [ "$status" = "1" ]; then
    echo -n "${bgreen}●${reset}"
  else
    echo -n "${bred}●${reset}"
  fi
}

# ── Language environment detection ───────────────────────────────────────────
detect_lang_env() {
  local d="$1"
  local langs=()

  if [ -f "$d/package.json" ] || [ -f "$d/.nvmrc" ] || [ -f "$d/.node-version" ]; then
    local nv; nv=$(node --version 2>/dev/null | sed 's/^v//')
    [ -n "$nv" ] && langs+=("${bgreen}node${reset}${dim}:${bwhite}${nv}${reset}")
    if [ -f "$d/bun.lockb" ]; then
      local bv; bv=$(bun --version 2>/dev/null)
      [ -n "$bv" ] && langs+=("${byellow}bun${reset}${dim}:${bwhite}${bv}${reset}")
    fi
  fi
  if [ -f "$d/pyproject.toml" ] || [ -f "$d/setup.py" ] || \
     [ -f "$d/requirements.txt" ] || [ -f "$d/.python-version" ]; then
    local py_bin=""
    if   [ -f "$d/.venv/bin/python" ];    then py_bin="$d/.venv/bin/python"
    elif command -v python3 &>/dev/null;  then py_bin="python3"
    elif command -v python  &>/dev/null;  then py_bin="python"
    fi
    if [ -n "$py_bin" ]; then
      local pv; pv=$("$py_bin" --version 2>&1 | awk '{print $2}')
      [ -n "$pv" ] && langs+=("${bblue}py${reset}${dim}:${bwhite}${pv}${reset}")
    fi
  fi
  if [ -f "$d/Gemfile" ] || [ -f "$d/.ruby-version" ]; then
    local rv; rv=$(ruby --version 2>/dev/null | awk '{print $2}')
    [ -n "$rv" ] && langs+=("${bred}rb${reset}${dim}:${bwhite}${rv}${reset}")
  fi
  if [ -f "$d/go.mod" ]; then
    local gv; gv=$(go version 2>/dev/null | awk '{print $3}' | sed 's/^go//')
    [ -n "$gv" ] && langs+=("${bcyan}go${reset}${dim}:${bwhite}${gv}${reset}")
  fi
  if [ -f "$d/Cargo.toml" ]; then
    local rsv; rsv=$(rustc --version 2>/dev/null | awk '{print $2}')
    [ -n "$rsv" ] && langs+=("${byellow}rs${reset}${dim}:${bwhite}${rsv}${reset}")
  fi
  if [ -f "$d/pom.xml" ] || [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ]; then
    local jv; jv=$(java -version 2>&1 | head -1 | sed 's/.*version "\(.*\)".*/\1/')
    [ -n "$jv" ] && langs+=("${bred}java${reset}${dim}:${bwhite}${jv}${reset}")
  fi
  if [ -f "$d/composer.json" ]; then
    local phpv; phpv=$(php --version 2>/dev/null | head -1 | awk '{print $2}')
    [ -n "$phpv" ] && langs+=("${bmagenta}php${reset}${dim}:${bwhite}${phpv}${reset}")
  fi
  if [ -f "$d/Package.swift" ] || ls "$d"/*.xcodeproj &>/dev/null 2>&1; then
    local swv; swv=$(swift --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
    [ -n "$swv" ] && langs+=("${byellow}swift${reset}${dim}:${bwhite}${swv}${reset}")
  fi
  if [ -f "$d/mix.exs" ]; then
    local exv; exv=$(elixir --version 2>/dev/null | grep Elixir | awk '{print $2}')
    [ -n "$exv" ] && langs+=("${bmagenta}ex${reset}${dim}:${bwhite}${exv}${reset}")
  fi
  if [ -f "$d/build.zig" ]; then
    local zigv; zigv=$(zig version 2>/dev/null)
    [ -n "$zigv" ] && langs+=("${byellow}zig${reset}${dim}:${bwhite}${zigv}${reset}")
  fi
  if [ -f "$d/deno.json" ] || [ -f "$d/deno.jsonc" ] || [ -f "$d/deno.lock" ]; then
    local dv; dv=$(deno --version 2>/dev/null | head -1 | awk '{print $2}')
    [ -n "$dv" ] && langs+=("${bgreen}deno${reset}${dim}:${bwhite}${dv}${reset}")
  fi

  if [ ${#langs[@]} -eq 0 ]; then return; fi
  local result=""
  for i in "${!langs[@]}"; do
    (( i > 0 )) && result+="${dim} · ${reset}"
    result+="${langs[$i]}"
  done
  echo -e "$result"
}

# ═════════════════════════════════════════════════════════════════════════════
# Line 1: [left]  spinner · model [ctx bar] · tokens · $cost · agent
#          [right] #session_id
# ═════════════════════════════════════════════════════════════════════════════
l1_left=""
l1_left+="$(net_badge) "
l1_left+="$(model_color "$model_name")${model_name}${reset}"
l1_left+=" $(build_ctx_bar "$ctx_remaining")"

# Token counts (session cumulative)
cache_hit=0
[ -n "$cache_read" ] && [ "$cache_read" != "null" ] && (( cache_hit = cache_read ))

l1_left+="${sep}${dim}in:${reset}$(format_tokens "$total_input" "$bgreen")"
l1_left+=" ${dim}cache:${reset}$(format_tokens "$cache_hit" "$bmagenta")"
l1_left+=" ${dim}out:${reset}$(format_tokens "$total_output" "$byellow")"

l1_left+="${sep}$(format_cost "$cost_usd")"

if [ -n "$agent_name" ]; then
  l1_left+="${sep}${bmagenta}⚡${agent_name}${reset}"
fi
if [ -n "$output_style" ] && [ "$output_style" != "default" ] && [ "$output_style" != "Default" ]; then
  l1_left+="${sep}${dim}style:${reset}${bwhite}${output_style}${reset}"
fi

l1_right=""
if [ -n "$session_id" ]; then
  l1_right+="${dim}#${reset}${bwhite}${session_id}${reset}"
fi

# Compose line 1
l1_ll=$(visible_len "$l1_left")
l1_rl=$(visible_len "$l1_right")
l1_pad=$(( cols - l1_ll - l1_rl ))
(( l1_pad < 1 )) && l1_pad=1
line1="${l1_left}$(printf '%*s' "$l1_pad" '')${l1_right}"

# ═════════════════════════════════════════════════════════════════════════════
# Line 2: [left]  dir · git branch + worktree + status · lang env
#          [right] ⚡ prompt_time │ ⏱ session_time
# ═════════════════════════════════════════════════════════════════════════════
short_cwd="${cwd/#$HOME/~}"
l2_left="${bblue}${short_cwd}${reset}"

if command -v git &>/dev/null; then
  git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  if [ -n "$git_branch" ]; then
    git_toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
    git_common=$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)
    worktree_label=""
    if [ -n "$git_common" ] && [ -n "$git_toplevel" ] && [ -f "$git_toplevel/.git" ]; then
      wt_name=$(basename "$git_toplevel")
      worktree_label="${dim}(wt:${reset}${byellow}${wt_name}${reset}${dim})${reset} "
    fi

    git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
    staged="" dirty="" untracked=""
    if echo "$git_status" | grep -qE "^[MADRC]"; then staged=" ${bgreen}●${reset}"; fi
    if echo "$git_status" | grep -qE "^.[MD]";   then dirty=" ${byellow}●${reset}"; fi
    if echo "$git_status" | grep -qE "^\?\?";    then untracked=" ${dim}●${reset}"; fi

    l2_left+="${sep}${worktree_label}${green}${git_branch}${reset}${staged}${dirty}${untracked}"
  fi
fi

lang_env=$(detect_lang_env "$cwd")
if [ -n "$lang_env" ]; then
  l2_left+="${sep}${lang_env}"
fi

# Right: session time
l2_right="${dim}⏱${reset} $(format_duration "$duration_ms")"

# Compose line 2
l2_ll=$(visible_len "$l2_left")
l2_rl=$(visible_len "$l2_right")
l2_pad=$(( cols - l2_ll - l2_rl ))
(( l2_pad < 1 )) && l2_pad=1
line2="${l2_left}$(printf '%*s' "$l2_pad" '')${l2_right}"

# ═════════════════════════════════════════════════════════════════════════════
echo -e "${line1}\n${line2}"
