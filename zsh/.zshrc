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
