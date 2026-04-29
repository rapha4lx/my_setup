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

is_yes() {
  case "$1" in
    y | Y | yes | YES | Yes | true | TRUE | True | 1) return 0 ;;
    *) return 1 ;;
  esac
}

can_prompt() {
  [ "${SETUP_MENU:-auto}" != "never" ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

ask_install() {
  label="$1"
  current="$2"

  if is_yes "$current"; then
    default="Y"
    prompt="[Y/n]"
  else
    default="N"
    prompt="[y/N]"
  fi

  printf 'Install %s? %s ' "$label" "$prompt" >/dev/tty
  IFS= read -r answer </dev/tty || answer=""

  if [ -z "$answer" ]; then
    answer="$default"
  fi

  if is_yes "$answer"; then
    printf '%s\n' "yes"
  else
    printf '%s\n' "no"
  fi
}

configure_menu() {
  INSTALL_BASE="${INSTALL_BASE:-yes}"
  INSTALL_DOCKER="${INSTALL_DOCKER:-yes}"
  INSTALL_LAZYDOCKER="${INSTALL_LAZYDOCKER:-yes}"
  INSTALL_LAZYVIM="${INSTALL_LAZYVIM:-yes}"
  INSTALL_OPENCODE="${INSTALL_OPENCODE:-yes}"
  INSTALL_OH_MY_OPENAGENT="${INSTALL_OH_MY_OPENAGENT:-yes}"
  INSTALL_OH_MY_ZSH="${INSTALL_OH_MY_ZSH:-yes}"
  CONFIGURE_ZSHRC="${CONFIGURE_ZSHRC:-yes}"
  SET_ZSH_DEFAULT="${SET_ZSH_DEFAULT:-yes}"

  if ! can_prompt; then
    return
  fi

  printf '\n%s\n' "Select what to install/configure:" >/dev/tty
  INSTALL_BASE="$(ask_install "base packages" "$INSTALL_BASE")"
  INSTALL_DOCKER="$(ask_install "Docker" "$INSTALL_DOCKER")"
  INSTALL_LAZYDOCKER="$(ask_install "LazyDocker" "$INSTALL_LAZYDOCKER")"
  INSTALL_LAZYVIM="$(ask_install "LazyVim" "$INSTALL_LAZYVIM")"
  INSTALL_OPENCODE="$(ask_install "OpenCode" "$INSTALL_OPENCODE")"
  INSTALL_OH_MY_OPENAGENT="$(ask_install "Oh My OpenAgent" "$INSTALL_OH_MY_OPENAGENT")"
  INSTALL_OH_MY_ZSH="$(ask_install "Oh My Zsh" "$INSTALL_OH_MY_ZSH")"
  CONFIGURE_ZSHRC="$(ask_install ".zshrc PATH and EDITOR setup" "$CONFIGURE_ZSHRC")"
  SET_ZSH_DEFAULT="$(ask_install "zsh as default shell" "$SET_ZSH_DEFAULT")"
  printf '\n' >/dev/tty
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
  if has apt-get; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find build-essential"
    run_as_root apt-get update
    run_as_root apt-get install -y $packages
  elif has dnf; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find gcc make"
    run_as_root dnf install -y $packages
  elif has yum; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find gcc make"
    run_as_root yum install -y $packages
  elif has pacman; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd base-devel"
    run_as_root pacman -Sy --noconfirm --needed $packages
  elif has apk; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd build-base"
    run_as_root apk add --no-cache $packages
  elif has zypper; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd gcc make"
    run_as_root zypper --non-interactive install $packages
  elif has brew; then
    packages="zsh curl git bash ca-certificates unzip gnu-tar neovim ripgrep fd gcc make"
    brew install $packages
  else
    die "No supported package manager found. Install zsh, curl, and git manually, then rerun this script."
  fi
}

current_user_name() {
  printf '%s\n' "${USER:-$(id -un 2>/dev/null || printf '')}"
}

prepend_user_bins_to_path() {
  export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
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

install_lazyvim() {
  nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

  if ! has nvim; then
    warn "Neovim is not available; skipping LazyVim starter clone"
    return
  fi

  if [ -e "$nvim_config_dir" ]; then
    log "Neovim config already exists at $nvim_config_dir; skipping LazyVim starter clone"
    return
  fi

  log "Installing LazyVim starter"
  mkdir -p "$(dirname "$nvim_config_dir")"
  git clone https://github.com/LazyVim/starter "$nvim_config_dir"
  rm -rf "$nvim_config_dir/.git"
}

install_opencode() {
  if has opencode; then
    log "OpenCode already installed"
    return
  fi

  if has brew; then
    log "Installing OpenCode with Homebrew"
    brew install anomalyco/tap/opencode
    return
  fi

  case "$(uname -s)" in
    Linux | Darwin)
      log "Installing OpenCode"
      curl -fsSL https://opencode.ai/install | bash
      prepend_user_bins_to_path
      ;;
    *)
      warn "Automatic OpenCode install is only configured for Linux, macOS, or Homebrew. Install OpenCode manually."
      ;;
  esac
}

install_bun() {
  if has bun && has bunx; then
    log "Bun already installed"
    return
  fi

  log "Installing Bun"
  curl -fsSL https://bun.sh/install | bash
  prepend_user_bins_to_path
}

install_oh_my_openagent() {
  if ! has opencode; then
    warn "OpenCode is not available; skipping Oh My OpenAgent install"
    return
  fi

  install_bun

  log "Installing Oh My OpenAgent"
  bunx oh-my-opencode install \
    --no-tui \
    --claude="${OMO_CLAUDE:-no}" \
    --openai="${OMO_OPENAI:-no}" \
    --gemini="${OMO_GEMINI:-no}" \
    --copilot="${OMO_COPILOT:-no}" \
    --opencode-zen="${OMO_OPENCODE_ZEN:-no}" \
    --zai-coding-plan="${OMO_ZAI_CODING_PLAN:-no}" \
    --opencode-go="${OMO_OPENCODE_GO:-no}" \
    --kimi-for-coding="${OMO_KIMI_FOR_CODING:-no}" \
    --vercel-ai-gateway="${OMO_VERCEL_AI_GATEWAY:-no}" \
    --skip-auth
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
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
export EDITOR="nvim"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
  elif ! grep -q 'oh-my-zsh.sh' "$zshrc"; then
    log "Adding Oh My Zsh to existing $zshrc"
    cat >>"$zshrc" <<'EOF'

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
export EDITOR="nvim"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
  else
    log "$zshrc already loads Oh My Zsh"
  fi

  if ! grep -q 'HOME/.opencode/bin' "$zshrc" || ! grep -q 'HOME/.bun/bin' "$zshrc"; then
    log "Adding user bin directories to PATH in $zshrc"
    cat >>"$zshrc" <<'EOF'

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
EOF
  fi

  if ! grep -q '^export EDITOR=' "$zshrc"; then
    log "Setting EDITOR to nvim in $zshrc"
    cat >>"$zshrc" <<'EOF'

export EDITOR="nvim"
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
  prepend_user_bins_to_path
  configure_menu

  if is_yes "$INSTALL_BASE"; then
    log "Installing required packages"
    install_packages
  fi
  if is_yes "$INSTALL_DOCKER"; then
    install_docker
  fi
  if is_yes "$INSTALL_LAZYDOCKER"; then
    install_lazydocker
  fi
  if is_yes "$INSTALL_LAZYVIM"; then
    install_lazyvim
  fi
  if is_yes "$INSTALL_OPENCODE"; then
    install_opencode
  fi
  if is_yes "$INSTALL_OH_MY_OPENAGENT"; then
    install_oh_my_openagent
  fi
  if is_yes "$INSTALL_OH_MY_ZSH"; then
    install_oh_my_zsh
  fi
  if is_yes "$CONFIGURE_ZSHRC"; then
    configure_zshrc
  fi
  if is_yes "$SET_ZSH_DEFAULT"; then
    set_default_shell
  fi

  log "Done. Open a new terminal or run: exec zsh"
}

main "$@"
