# Loaded automatically by Oh My Zsh from $ZSH_CUSTOM.

export NVM_DIR="$HOME/.nvm"
export MY_SETUP_RESTORE_LAST_DIR="${MY_SETUP_RESTORE_LAST_DIR:-yes}"
export MY_SETUP_LAST_DIR_FILE="${MY_SETUP_LAST_DIR_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/my_setup/last_dir}"

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

save-last-dir() {
  local last_dir_file last_dir_dir

  [ "$MY_SETUP_RESTORE_LAST_DIR" = yes ] || return 0
  [ -n "$PWD" ] || return 0

  last_dir_file="$MY_SETUP_LAST_DIR_FILE"
  last_dir_dir="${last_dir_file%/*}"

  mkdir -p "$last_dir_dir" >/dev/null 2>&1 || return 0
  printf '%s\n' "$PWD" >"$last_dir_file" 2>/dev/null || true
}

restore-last-dir() {
  local last_dir_file last_dir

  [ "$MY_SETUP_RESTORE_LAST_DIR" = yes ] || return 0
  [[ -o interactive ]] || return 0
  [ "$PWD" = "$HOME" ] || return 0

  last_dir_file="$MY_SETUP_LAST_DIR_FILE"
  [ -f "$last_dir_file" ] || return 0

  IFS= read -r last_dir <"$last_dir_file" || return 0
  [ -n "$last_dir" ] || return 0
  [ -d "$last_dir" ] || return 0

  cd -- "$last_dir" 2>/dev/null || return 0
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd save-last-dir
restore-last-dir

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
