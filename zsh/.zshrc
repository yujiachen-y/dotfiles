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

# oh-my-zsh plugins
source ~/.oh-my-zsh/lib/directories.zsh
source ~/.oh-my-zsh/lib/git.zsh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh
source ~/.oh-my-zsh/plugins/z/z.plugin.zsh

source ~/.non_public_commands.sh

alias gbdd="git branch | grep -vF "main" | xargs git branch -D"
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
