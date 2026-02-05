# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="/usr/local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# poetry
if [ ! -f ~/.zfunc/_poetry ]; then
  mkdir -p ~/.zfunc
fi
poetry completions zsh > ~/.zfunc/_poetry
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

klnd() {
  echo "Searching for running Node.js processes..."
  local NODE_PROCESSES=$(ps aux | grep node | grep -v grep)

  if [ -z "$NODE_PROCESSES" ]; then
    echo "No running Node.js processes found."
    return 0
  fi

  echo "Found the following Node.js processes:"
  ps aux | grep node | grep -v grep | awk '{printf "%-10s %.64s...\n", $2, $11}'

  echo "Terminating Node.js processes..."
  ps aux | grep node | grep -v grep | awk '{print $2}' | xargs kill -9
  echo "All Node.js processes have been terminated."
}

# oh-my-zsh plugins
source ~/.oh-my-zsh/lib/directories.zsh
source ~/.oh-my-zsh/lib/git.zsh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh
source ~/.oh-my-zsh/plugins/z/z.plugin.zsh

# powerlevel10k
P10K_THEME="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"
if [ -r "$P10K_THEME" ]; then
  source "$P10K_THEME"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/.non_public_commands.sh

alias gbdd='
  git branch --format="%(refname:short)" \
  | grep -vx "main" \
  | xargs git branch -D
'
alias godd="find . -type f -name '*.orig' -delete"

# Run `gcsh <$KEYWORD>` to ssh into files
gcsh() {
  KEYWORD=${1}
  shift
  # Get all gcloud vm having the KEYWORD in name
  HOSTLINE=$(gcloud compute instances list --filter="${KEYWORD}" | grep RUNNING | fzf -1 -0)
  if [[ -n "${HOSTLINE}" ]]; then
    read -r NAME ZONE NOTHING <<< "${HOSTLINE}"
    # ssh and sudo -i
    gcloud compute ssh ${NAME} --zone=${ZONE} --tunnel-through-iap -- -t sudo -i;
  fi
}

agents_link() {
  local TARGET_DIR="${1:-$PWD}"

  if [ ! -d "${TARGET_DIR}" ]; then
    echo "Directory not found: ${TARGET_DIR}"
    return 1
  fi

  # Link AGENTS.md -> GEMINI.md, CLAUDE.md
  if [ -f "${TARGET_DIR}/AGENTS.md" ]; then
    (
      cd "${TARGET_DIR}" \
        && ln -snf "AGENTS.md" "GEMINI.md" \
        && ln -snf "AGENTS.md" "CLAUDE.md"
    )
    echo "Linked: AGENTS.md -> GEMINI.md, CLAUDE.md"
  else
    echo "Warning: AGENTS.md not found in ${TARGET_DIR}"
  fi

  # Link .agent/ -> .gemini/, .claude/
  if [ -d "${TARGET_DIR}/.agent" ]; then
    (
      cd "${TARGET_DIR}" \
        && ln -snf ".agent" ".gemini" \
        && ln -snf ".agent" ".claude"
    )
    echo "Linked: .agent/ -> .gemini/, .claude/"

    # Special handling for .codex
    local CODEX_CREATED=0
    if [ -d "${TARGET_DIR}/.agent/commands" ]; then
      mkdir -p "${TARGET_DIR}/.codex"
      CODEX_CREATED=1
      (
        cd "${TARGET_DIR}/.codex" \
          && ln -snf "../.agent/commands" "prompts"
      )
      echo "Linked: .agent/commands/ -> .codex/prompts/"
    fi
    if [ -d "${TARGET_DIR}/.agent/skills" ]; then
      if [ $CODEX_CREATED -eq 0 ]; then
        mkdir -p "${TARGET_DIR}/.codex"
      fi
      (
        cd "${TARGET_DIR}/.codex" \
          && ln -snf "../.agent/skills" "skills"
      )
      echo "Linked: .agent/skills/ -> .codex/skills/"
    fi
  else
    echo "Warning: .agent/ not found in ${TARGET_DIR}, skipping folder links"
  fi
}

# antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# codex
eval "$(codex completion zsh)"

# added by claude-code
export PATH="$HOME/.local/bin:$PATH"

alias ccyl="claude --dangerously-skip-permissions"
alias cxyl="codex --yolo"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
