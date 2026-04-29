# Loaded automatically by Oh My Zsh from $ZSH_CUSTOM.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
command -v nvm >/dev/null 2>&1 && nvm use default >/dev/null 2>&1

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
