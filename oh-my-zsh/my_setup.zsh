# Loaded automatically by Oh My Zsh from $ZSH_CUSTOM.

export NVM_DIR="$HOME/.nvm"

load-nvm() {
  unset -f node npm npx nvm
  [ -s "$NVM_DIR/nvm.sh" ] || return 127
  source "$NVM_DIR/nvm.sh"
  nvm use default >/dev/null 2>&1 || true
}

node() {
  load-nvm && command node "$@"
}

npm() {
  load-nvm && command npm "$@"
}

npx() {
  load-nvm && command npx "$@"
}

nvm() {
  load-nvm && nvm "$@"
}

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias ll="ls -lah"
alias lg="lazydocker"

ctls() {
  docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}'
}
