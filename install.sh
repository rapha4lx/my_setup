#!/usr/bin/env sh
set -eu

log() {
  printf '%s\n' "==> $*"
}

warn() {
  printf '%s\n' "WARN: $*" >&2
}

die() {
  printf '%s\n' "ERROR: $*" >&2
  exit 1
}

has() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif has sudo; then
    sudo "$@"
  else
    die "This step needs root privileges. Install sudo or run as root."
  fi
}

install_packages() {
  packages="zsh curl git bash ca-certificates"

  if has apt-get; then
    run_as_root apt-get update
    run_as_root apt-get install -y $packages
  elif has dnf; then
    run_as_root dnf install -y $packages
  elif has yum; then
    run_as_root yum install -y $packages
  elif has pacman; then
    run_as_root pacman -Sy --noconfirm --needed $packages
  elif has apk; then
    run_as_root apk add --no-cache $packages
  elif has zypper; then
    run_as_root zypper --non-interactive install $packages
  elif has brew; then
    brew install $packages
  else
    die "No supported package manager found. Install zsh, curl, and git manually, then rerun this script."
  fi
}

current_user_name() {
  printf '%s\n' "${USER:-$(id -un 2>/dev/null || printf '')}"
}

add_user_to_docker_group() {
  user_name="$(current_user_name)"
  [ -n "$user_name" ] || return

  if has getent && ! getent group docker >/dev/null 2>&1; then
    if has groupadd; then
      run_as_root groupadd docker || warn "Could not create docker group"
    elif has addgroup; then
      run_as_root addgroup docker || warn "Could not create docker group"
    fi
  fi

  if has usermod; then
    run_as_root usermod -aG docker "$user_name" || warn "Could not add $user_name to docker group"
  elif has adduser; then
    run_as_root adduser "$user_name" docker || warn "Could not add $user_name to docker group"
  else
    warn "Could not find usermod or adduser to add $user_name to docker group"
    return
  fi

  warn "Log out and back in before running docker without sudo."
}

install_docker() {
  if has docker; then
    log "Docker already installed"
    return
  fi

  if has brew; then
    log "Installing Docker with Homebrew"
    brew install --cask docker || brew install docker
    return
  fi

  case "$(uname -s)" in
    Linux)
      log "Installing Docker with Docker's convenience script"
      docker_script="$(mktemp)"
      curl -fsSL https://get.docker.com -o "$docker_script"
      run_as_root sh "$docker_script"
      rm -f "$docker_script"
      ;;
    *)
      warn "Automatic Docker install is only configured for Linux or Homebrew. Install Docker manually."
      return
      ;;
  esac

  if has systemctl; then
    run_as_root systemctl enable --now docker || warn "Could not enable/start docker with systemctl"
  fi

  add_user_to_docker_group
}

install_lazydocker() {
  if has lazydocker; then
    log "LazyDocker already installed"
    return
  fi

  if has brew; then
    log "Installing LazyDocker with Homebrew"
    brew install jesseduffield/lazydocker/lazydocker || brew install lazydocker
    return
  fi

  case "$(uname -s)" in
    Linux)
      log "Installing LazyDocker"
      lazydocker_dir="${LAZYDOCKER_DIR:-$HOME/.local/bin}"
      mkdir -p "$lazydocker_dir"
      curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR="$lazydocker_dir" bash
      ;;
    *)
      warn "Automatic LazyDocker install is only configured for Linux or Homebrew. Install LazyDocker manually."
      ;;
  esac
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh already installed"
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

configure_zshrc() {
  zshrc="$HOME/.zshrc"

  if [ ! -f "$zshrc" ]; then
    log "Creating $zshrc"
    cat >"$zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
  elif ! grep -q 'oh-my-zsh.sh' "$zshrc"; then
    log "Adding Oh My Zsh to existing $zshrc"
    cat >>"$zshrc" <<'EOF'

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
  else
    log "$zshrc already loads Oh My Zsh"
  fi

  if ! grep -q 'HOME/.local/bin' "$zshrc"; then
    log "Adding $HOME/.local/bin to PATH in $zshrc"
    cat >>"$zshrc" <<'EOF'

export PATH="$HOME/.local/bin:$PATH"
EOF
  fi
}

set_default_shell() {
  zsh_path="$(command -v zsh || true)"
  [ -n "$zsh_path" ] || die "zsh is not available after installation."

  user_name="$(current_user_name)"
  if has getent && [ -n "$user_name" ]; then
    current_shell="$(getent passwd "$user_name" 2>/dev/null | cut -d: -f7 || printf '')"
  else
    current_shell="${SHELL:-}"
  fi

  if [ "$current_shell" = "$zsh_path" ]; then
    log "Default shell is already zsh"
    return
  fi

  if has chsh; then
    log "Setting zsh as the default shell"
    if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
      printf '%s\n' "$zsh_path" | run_as_root tee -a /etc/shells >/dev/null
    fi
    chsh -s "$zsh_path" || warn "Could not change shell automatically. Run: chsh -s $zsh_path"
  else
    warn "chsh not found. Set your default shell manually to: $zsh_path"
  fi
}

main() {
  log "Installing required packages"
  install_packages
  install_docker
  install_lazydocker
  install_oh_my_zsh
  configure_zshrc
  set_default_shell

  log "Done. Open a new terminal or run: exec zsh"
}

main "$@"
