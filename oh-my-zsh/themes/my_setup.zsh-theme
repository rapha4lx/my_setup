prompt_my_setup_git_branch() {
  command git symbolic-ref --short HEAD 2>/dev/null ||
    command git rev-parse --short HEAD 2>/dev/null
}

prompt_my_setup_git_status() {
  command git diff --quiet --ignore-submodules -- 2>/dev/null &&
    command git diff --cached --quiet --ignore-submodules -- 2>/dev/null
}

prompt_my_setup_git() {
  branch="$(prompt_my_setup_git_branch)"
  [ -n "$branch" ] || return

  if prompt_my_setup_git_status; then
    printf ' %%F{cyan}git:(%%F{green}%s%%F{cyan})%%f' "$branch"
  else
    printf ' %%F{cyan}git:(%%F{yellow}%s%%F{red}*%%F{cyan})%%f' "$branch"
  fi
}

prompt_my_setup_ip() {
  if command -v ip >/dev/null 2>&1; then
    command ip route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i <= NF; i++) if ($i == "src") {print $(i + 1); exit}}'
  elif command -v ifconfig >/dev/null 2>&1; then
    command ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
  fi
}

PROMPT='%(?.%F{green}.%F{red})%n%f@%F{blue}%m%f %F{magenta}%~%f$(prompt_my_setup_git)
%F{green}>%f '
RPROMPT='%F{yellow}%D{%H:%M:%S}%f %F{cyan}$(prompt_my_setup_ip)%f'
