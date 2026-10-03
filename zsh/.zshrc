# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="/usr/local/bin:$PATH"

autoload -Uz compinit && compinit

# mise (sole owner of node, python and go; Python CLIs install via `uv tool`)
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# Default editor for terminal tools that use $VISUAL/$EDITOR.
export VISUAL="zed --wait"
export EDITOR="zed --wait"

# oh-my-zsh plugins
source ~/.oh-my-zsh/lib/directories.zsh
source ~/.oh-my-zsh/lib/git.zsh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh
source ~/.oh-my-zsh/plugins/z/z.plugin.zsh

# zsh autosuggestions (history-based inline suggestions)
if command -v brew >/dev/null 2>&1; then
  ZSH_AUTOSUGGESTIONS_FILE="$(brew --prefix zsh-autosuggestions 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -r "$ZSH_AUTOSUGGESTIONS_FILE" ] && source "$ZSH_AUTOSUGGESTIONS_FILE"
  unset ZSH_AUTOSUGGESTIONS_FILE
fi

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
# ~/Workspace checkouts: `ws pull` updates them all, `ws add <repo>` clones into place.
alias ws='sh ~/dotfiles/workspace/repos.sh'

# codex
eval "$(codex completion zsh)"

# added by claude-code
export PATH="$HOME/.local/bin:$PATH"

# alias ccyl="CLAUDE_CODE_NO_FLICKER=1 claude --dangerously-skip-permissions --effort max --disallowedTools \"Agent(Explore)\" \"Agent(claude-code-guide)\""
# alias cxyl="codex --yolo"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# MiniMax Code
export PATH="$HOME/.minimax/bin:$PATH"
