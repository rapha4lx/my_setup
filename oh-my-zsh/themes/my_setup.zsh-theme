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

prompt_my_setup_container_id() {
  if [ -n "$container" ]; then
    printf '%s\n' "$container"
  elif [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    command hostname 2>/dev/null
  elif [ -r /proc/1/cpuset ]; then
    awk -F/ '/docker|kubepods|containerd|libpod/ {print $NF; exit}' /proc/1/cpuset 2>/dev/null | cut -c 1-12
  fi
}

prompt_my_setup_container_info() {
  container_id="$(prompt_my_setup_container_id)"
  [ -n "$container_id" ] || return

  container_ip="$(prompt_my_setup_ip)"
  if [ -n "$container_ip" ]; then
    printf ' docker:%s %s' "$container_id" "$container_ip"
  else
    printf ' docker:%s' "$container_id"
  fi
}

prompt_my_setup_right() {
  container_info="$(prompt_my_setup_container_info)"
  if [ -n "$container_info" ]; then
    printf '%%F{yellow}%%D{%%H:%%M:%%S}%%f %%F{red}%s%%f' "$container_info"
  else
    printf '%%F{yellow}%%D{%%H:%%M:%%S}%%f %%F{cyan}%s%%f' "$(prompt_my_setup_ip)"
  fi
}

PROMPT='%(?.%F{green}.%F{red})%n%f %F{magenta}%~%f$(prompt_my_setup_git)
%F{green}>%f '
RPROMPT='$(prompt_my_setup_right)'
