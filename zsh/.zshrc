export PATH="/usr/local/bin:$PATH"

# proxy
[[ ! -f ~/.proxy.zsh ]] || source ~/.proxy.zsh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# oh-my-zsh plugins
source ~/.oh-my-zsh/lib/directories.zsh
source ~/.oh-my-zsh/lib/git.zsh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh
source ~/.oh-my-zsh/plugins/z/z.plugin.zsh
