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

PROMPT='%(?.%F{green}.%F{red})%n%f@%F{blue}%m%f %F{magenta}%~%f$(prompt_my_setup_git)
%F{green}>%f '

