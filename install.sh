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

cleanup_and_exit() {
  if [ -n "${MENU_TTY_STATE:-}" ]; then
    stty "$MENU_TTY_STATE" </dev/tty 2>/dev/null || true
  fi
  printf '\n%s\n' "Interrupted. Exiting." >&2
  exit 130
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
  [ "${SETUP_MENU:-auto}" != "never" ] &&
    ( : </dev/tty ) >/dev/null 2>&1 &&
    ( : >/dev/tty ) >/dev/null 2>&1
}

configure_menu() {
  INSTALL_BASE="${INSTALL_BASE:-yes}"
  INSTALL_GH="${INSTALL_GH:-yes}"
  INSTALL_DOCKER="${INSTALL_DOCKER:-yes}"
  INSTALL_LAZYDOCKER="${INSTALL_LAZYDOCKER:-yes}"
  INSTALL_NODE20="${INSTALL_NODE20:-yes}"
  INSTALL_LAZYVIM_STACK="${INSTALL_LAZYVIM_STACK:-yes}"
  INSTALL_OPENCODE="${INSTALL_OPENCODE:-yes}"
  INSTALL_OH_MY_OPENAGENT="${INSTALL_OH_MY_OPENAGENT:-yes}"
  INSTALL_OH_MY_ZSH="${INSTALL_OH_MY_ZSH:-yes}"
  INSTALL_CUSTOM_OH_MY_ZSH="${INSTALL_CUSTOM_OH_MY_ZSH:-yes}"
  CONFIGURE_ZSHRC="${CONFIGURE_ZSHRC:-yes}"
  SET_ZSH_DEFAULT="${SET_ZSH_DEFAULT:-yes}"

  if ! can_prompt; then
    return
  fi

  checkbox_menu
  printf '\n' >/dev/tty
}

menu_count() {
  printf '%s\n' 12
}

menu_label() {
  case "$1" in
    1) printf '%s\n' "Base packages" ;;
    2) printf '%s\n' "GitHub CLI" ;;
    3) printf '%s\n' "Docker" ;;
    4) printf '%s\n' "LazyDocker" ;;
    5) printf '%s\n' "NVM + Node.js 20" ;;
    6) printf '%s\n' "LazyVim stack" ;;
    7) printf '%s\n' "OpenCode" ;;
    8) printf '%s\n' "Oh My OpenAgent" ;;
    9) printf '%s\n' "Oh My Zsh" ;;
    10) printf '%s\n' "custom Oh My Zsh file" ;;
    11) printf '%s\n' ".zshrc PATH and EDITOR setup" ;;
    12) printf '%s\n' "zsh as default shell" ;;
  esac
}

menu_value() {
  case "$1" in
    1) printf '%s\n' "$INSTALL_BASE" ;;
    2) printf '%s\n' "$INSTALL_GH" ;;
    3) printf '%s\n' "$INSTALL_DOCKER" ;;
    4) printf '%s\n' "$INSTALL_LAZYDOCKER" ;;
    5) printf '%s\n' "$INSTALL_NODE20" ;;
    6) printf '%s\n' "$INSTALL_LAZYVIM_STACK" ;;
    7) printf '%s\n' "$INSTALL_OPENCODE" ;;
    8) printf '%s\n' "$INSTALL_OH_MY_OPENAGENT" ;;
    9) printf '%s\n' "$INSTALL_OH_MY_ZSH" ;;
    10) printf '%s\n' "$INSTALL_CUSTOM_OH_MY_ZSH" ;;
    11) printf '%s\n' "$CONFIGURE_ZSHRC" ;;
    12) printf '%s\n' "$SET_ZSH_DEFAULT" ;;
  esac
}

menu_set() {
  case "$1" in
    1) INSTALL_BASE="$2" ;;
    2) INSTALL_GH="$2" ;;
    3) INSTALL_DOCKER="$2" ;;
    4) INSTALL_LAZYDOCKER="$2" ;;
    5) INSTALL_NODE20="$2" ;;
    6) INSTALL_LAZYVIM_STACK="$2" ;;
    7) INSTALL_OPENCODE="$2" ;;
    8) INSTALL_OH_MY_OPENAGENT="$2" ;;
    9) INSTALL_OH_MY_ZSH="$2" ;;
    10) INSTALL_CUSTOM_OH_MY_ZSH="$2" ;;
    11) CONFIGURE_ZSHRC="$2" ;;
    12) SET_ZSH_DEFAULT="$2" ;;
  esac
}

menu_toggle() {
  if is_yes "$(menu_value "$1")"; then
    menu_set "$1" "no"
  else
    menu_set "$1" "yes"
  fi
}

draw_checkbox_menu() {
  selected="$1"
  count="$(menu_count)"
  i=1

  if has tput; then
    tput clear >/dev/tty 2>/dev/null || printf '\033c' >/dev/tty
  else
    printf '\033c' >/dev/tty
  fi

  printf '%s\n' "Select what to install/configure" >/dev/tty
  printf '%s\n\n' "Use arrows, j/k, or w/s to move, Space to toggle, Enter to install." >/dev/tty

  while [ "$i" -le "$count" ]; do
    marker=" "
    pointer=" "

    if is_yes "$(menu_value "$i")"; then
      marker="x"
    fi
    if [ "$i" -eq "$selected" ]; then
      pointer=">"
    fi

    printf '%s [%s] %s\n' "$pointer" "$marker" "$(menu_label "$i")" >/dev/tty
    i=$((i + 1))
  done
}

read_menu_key() {
  MENU_TTY_STATE="$(stty -g </dev/tty)"
  esc="$(printf '\033')"
  stty raw -echo min 1 time 0 </dev/tty
  key="$(dd bs=1 count=1 2>/dev/null </dev/tty || true)"

  if [ "$key" = "$esc" ]; then
    stty raw -echo min 0 time 1 </dev/tty
    key="$key$(dd bs=1 count=1 2>/dev/null </dev/tty || true)"
    key="$key$(dd bs=1 count=1 2>/dev/null </dev/tty || true)"
  fi

  stty "$MENU_TTY_STATE" </dev/tty 2>/dev/null || true
  MENU_TTY_STATE=""
  printf '%s' "$key"
}

checkbox_menu() {
  selected=1
  count="$(menu_count)"

  while :; do
    draw_checkbox_menu "$selected"
    key="$(read_menu_key)"

    case "$key" in
      "$(printf '\003')")
        cleanup_and_exit
        ;;
      j | s | "$(printf '\033[B')")
        if [ "$selected" -lt "$count" ]; then
          selected=$((selected + 1))
        else
          selected=1
        fi
        ;;
      k | w | "$(printf '\033[A')")
        if [ "$selected" -gt 1 ]; then
          selected=$((selected - 1))
        else
          selected="$count"
        fi
        ;;
      " ")
        menu_toggle "$selected"
        ;;
      "$(printf '\r')" | "$(printf '\n')" | "")
        break
        ;;
    esac
  done
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
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find build-essential npm"
    run_as_root apt-get update
    run_as_root apt-get install -y $packages
  elif has dnf; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find gcc make npm"
    run_as_root dnf install -y $packages
  elif has yum; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd-find gcc make npm"
    run_as_root yum install -y $packages
  elif has pacman; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd base-devel npm"
    run_as_root pacman -Sy --noconfirm --needed $packages
  elif has apk; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd build-base npm"
    run_as_root apk add --no-cache $packages
  elif has zypper; then
    packages="zsh curl git bash ca-certificates unzip tar neovim ripgrep fd gcc make npm"
    run_as_root zypper --non-interactive install $packages
  elif has brew; then
    packages="zsh curl git bash ca-certificates unzip gnu-tar neovim ripgrep fd gcc make node"
    brew install $packages
  else
    die "No supported package manager found. Install zsh, curl, and git manually, then rerun this script."
  fi
}

install_gh() {
  if has gh; then
    log "GitHub CLI already installed"
    return
  fi

  log "Installing GitHub CLI"
  if has apt-get; then
    run_as_root mkdir -p /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
      run_as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    run_as_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$(dpkg --print-architecture)" |
      run_as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    run_as_root apt-get update
    run_as_root apt-get install -y gh
  elif has dnf; then
    run_as_root dnf install -y dnf5-plugins >/dev/null 2>&1 || run_as_root dnf install -y 'dnf-command(config-manager)'
    run_as_root dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    run_as_root dnf install -y gh --repo gh-cli
  elif has yum; then
    run_as_root yum install -y yum-utils
    run_as_root yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    run_as_root yum install -y gh
  elif has pacman; then
    run_as_root pacman -Sy --noconfirm --needed github-cli
  elif has apk; then
    run_as_root apk add --no-cache github-cli
  elif has zypper; then
    run_as_root zypper --non-interactive install gh
  elif has brew; then
    brew install gh
  else
    warn "No supported package manager found for GitHub CLI. Install gh manually."
  fi
}

current_user_name() {
  printf '%s\n' "${USER:-$(id -un 2>/dev/null || printf '')}"
}

prepend_user_bins_to_path() {
  export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
}

load_nvm() {
  nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  if [ -s "$nvm_dir/nvm.sh" ]; then
    export NVM_DIR="$nvm_dir"
    # shellcheck disable=SC1090
    . "$nvm_dir/nvm.sh"
    nvm use default >/dev/null 2>&1 || true
  fi
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

install_nvm_node20() {
  node_major="${NODE_VERSION:-20}"
  nvm_dir="${NVM_DIR:-$HOME/.nvm}"

  if [ ! -s "$nvm_dir/nvm.sh" ]; then
    log "Installing NVM"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
  fi

  load_nvm
  if ! has nvm; then
    warn "NVM was not loaded; skipping Node.js $node_major install"
    return
  fi

  log "Installing Node.js $node_major with NVM"
  nvm install "$node_major"
  nvm alias default "$node_major"
  nvm use default
}

nvim_version() {
  if has nvim; then
    nvim --version 2>/dev/null | sed -n '1s/^NVIM v//p' | sed 's/[^0-9.].*$//'
  fi
}

version_ge() {
  awk -v current="$1" -v required="$2" '
    BEGIN {
      split(current, c, ".")
      split(required, r, ".")
      for (i = 1; i <= 3; i++) {
        cv = c[i] + 0
        rv = r[i] + 0
        if (cv > rv) exit 0
        if (cv < rv) exit 1
      }
      exit 0
    }
  '
}

install_neovim_package() {
  if has apt-get; then
    run_as_root apt-get update
    run_as_root apt-get install -y neovim
  elif has dnf; then
    run_as_root dnf install -y neovim
  elif has yum; then
    run_as_root yum install -y neovim
  elif has pacman; then
    run_as_root pacman -Sy --noconfirm --needed neovim
  elif has apk; then
    run_as_root apk add --no-cache neovim
  elif has zypper; then
    run_as_root zypper --non-interactive install neovim
  elif has brew; then
    brew install neovim || brew upgrade neovim
  else
    return 1
  fi
}

install_neovim_official_release() {
  os_name="$(uname -s)"
  arch_name="$(uname -m)"

  case "$os_name:$arch_name" in
    Linux:x86_64 | Linux:amd64)
      archive_name="nvim-linux-x86_64"
      ;;
    Linux:aarch64 | Linux:arm64)
      archive_name="nvim-linux-arm64"
      ;;
    Darwin:x86_64)
      archive_name="nvim-macos-x86_64"
      ;;
    Darwin:arm64 | Darwin:aarch64)
      archive_name="nvim-macos-arm64"
      ;;
    *)
      warn "Official Neovim archive is not configured for $os_name/$arch_name"
      return 1
      ;;
  esac

  has tar || die "tar is required to install the official Neovim archive."

  archive_path="/tmp/${archive_name}.tar.gz"
  install_dir="/opt/$archive_name"
  download_url="https://github.com/neovim/neovim/releases/latest/download/${archive_name}.tar.gz"

  log "Installing official Neovim release from $download_url"
  curl -fsSL "$download_url" -o "$archive_path"
  run_as_root mkdir -p /opt /usr/local/bin
  run_as_root rm -rf "$install_dir"
  run_as_root tar -C /opt -xzf "$archive_path"
  run_as_root ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
  rm -f "$archive_path"
}

install_neovim() {
  required_nvim_version="${NEOVIM_MIN_VERSION:-0.11.2}"
  current_nvim_version="$(nvim_version || true)"

  if [ -n "$current_nvim_version" ] && version_ge "$current_nvim_version" "$required_nvim_version"; then
    log "Neovim $current_nvim_version already installed"
    return
  fi

  if [ -n "$current_nvim_version" ]; then
    warn "Neovim $current_nvim_version is older than required $required_nvim_version"
  else
    log "Neovim is not installed"
  fi

  install_neovim_package || warn "No supported package manager found for Neovim package install."
  current_nvim_version="$(nvim_version || true)"

  if [ -n "$current_nvim_version" ] && version_ge "$current_nvim_version" "$required_nvim_version"; then
    log "Neovim $current_nvim_version installed"
    return
  fi

  install_neovim_official_release || warn "Could not install official Neovim release."
  current_nvim_version="$(nvim_version || true)"

  if [ -z "$current_nvim_version" ] || ! version_ge "$current_nvim_version" "$required_nvim_version"; then
    die "Neovim $required_nvim_version or newer is required for LazyVim."
  fi

  log "Neovim $current_nvim_version installed"
}

install_lazyvim() {
  nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  required_nvim_version="${NEOVIM_MIN_VERSION:-0.11.2}"
  current_nvim_version="$(nvim_version || true)"

  if [ -z "$current_nvim_version" ] || ! version_ge "$current_nvim_version" "$required_nvim_version"; then
    warn "Neovim $required_nvim_version or newer is required; skipping LazyVim starter clone"
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

install_tree_sitter_cli() {
  if has tree-sitter; then
    log "tree-sitter CLI already installed"
    return
  fi

  if has npm; then
    log "Installing tree-sitter CLI with npm"
    npm_path="$(command -v npm)"
    case "$npm_path" in
      "$HOME"/.nvm/*)
        npm install -g tree-sitter-cli
        ;;
      *)
        run_as_root npm install -g tree-sitter-cli
        ;;
    esac
  elif has bun; then
    log "Installing tree-sitter CLI with bun"
    bun install -g tree-sitter-cli
  else
    warn "npm or bun is required to install tree-sitter CLI automatically"
  fi
}

update_lazyvim() {
  nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  required_nvim_version="${NEOVIM_MIN_VERSION:-0.11.2}"
  current_nvim_version="$(nvim_version || true)"

  if [ -z "$current_nvim_version" ] || ! version_ge "$current_nvim_version" "$required_nvim_version"; then
    warn "Neovim $required_nvim_version or newer is required; skipping LazyVim update"
    return
  fi

  if [ ! -f "$nvim_config_dir/init.lua" ]; then
    warn "LazyVim config not found at $nvim_config_dir; skipping LazyVim update"
    return
  fi

  log "Updating LazyVim plugins"
  nvim --headless -u "$nvim_config_dir/init.lua" "+Lazy! sync" +qa
  nvim --headless -u "$nvim_config_dir/init.lua" "+Lazy! sync" +qa
}

install_lazyvim_stack() {
  install_neovim
  install_lazyvim
  install_tree_sitter_cli
  update_lazyvim
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

install_custom_oh_my_zsh() {
  zsh_custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  custom_target="$zsh_custom_dir/my_setup.zsh"
  custom_source="${CUSTOM_OH_MY_ZSH_SOURCE:-https://raw.githubusercontent.com/rapha4lx/my_setup/main/oh-my-zsh/my_setup.zsh}"
  theme_dir="$zsh_custom_dir/themes"
  theme_target="$theme_dir/my_setup.zsh-theme"
  theme_source="${CUSTOM_OH_MY_ZSH_THEME_SOURCE:-https://raw.githubusercontent.com/rapha4lx/my_setup/main/oh-my-zsh/themes/my_setup.zsh-theme}"

  if [ ! -d "$zsh_custom_dir" ]; then
    warn "Oh My Zsh custom directory not found at $zsh_custom_dir; skipping custom file"
    return
  fi

  log "Installing custom Oh My Zsh file"
  case "$custom_source" in
    http://* | https://*)
      curl -fsSL "$custom_source" -o "$custom_target"
      ;;
    *)
      cp "$custom_source" "$custom_target"
      ;;
  esac

  log "Installing custom Oh My Zsh theme"
  mkdir -p "$theme_dir"
  case "$theme_source" in
    http://* | https://*)
      curl -fsSL "$theme_source" -o "$theme_target"
      ;;
    *)
      cp "$theme_source" "$theme_target"
      ;;
  esac
}

configure_zshrc() {
  zshrc="$HOME/.zshrc"

  if [ ! -f "$zshrc" ]; then
    log "Creating $zshrc"
    cat >"$zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
export EDITOR="nvim"
ZSH_THEME="my_setup"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
if [ -f "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh" ]; then
  source "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh"
fi
EOF
  elif ! grep -q 'oh-my-zsh.sh' "$zshrc"; then
    log "Adding Oh My Zsh to existing $zshrc"
    cat >>"$zshrc" <<'EOF'

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"
export EDITOR="nvim"
ZSH_THEME="my_setup"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
if [ -f "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh" ]; then
  source "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh"
fi
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

  if grep -q '^ZSH_THEME=' "$zshrc"; then
    theme_tmp="${zshrc}.my_setup.$$"
    sed 's/^ZSH_THEME=.*/ZSH_THEME="my_setup"/' "$zshrc" >"$theme_tmp"
    mv "$theme_tmp" "$zshrc"
  else
    log "Setting Oh My Zsh theme to my_setup in $zshrc"
    cat >>"$zshrc" <<'EOF'

ZSH_THEME="my_setup"
EOF
  fi

  if ! grep -q 'my_setup.zsh' "$zshrc"; then
    log "Adding custom Oh My Zsh file autoload to $zshrc"
    cat >>"$zshrc" <<'EOF'

if [ -f "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh" ]; then
  source "${ZSH_CUSTOM:-$ZSH/custom}/my_setup.zsh"
fi
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
  trap cleanup_and_exit INT TERM

  prepend_user_bins_to_path
  configure_menu

  if is_yes "$INSTALL_BASE"; then
    log "Installing required packages"
    install_packages
  fi
  if is_yes "$INSTALL_GH"; then
    install_gh
  fi
  if is_yes "$INSTALL_DOCKER"; then
    install_docker
  fi
  if is_yes "$INSTALL_LAZYDOCKER"; then
    install_lazydocker
  fi
  if is_yes "$INSTALL_NODE20"; then
    install_nvm_node20
  fi
  if is_yes "$INSTALL_LAZYVIM_STACK"; then
    install_lazyvim_stack
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
  if is_yes "$INSTALL_CUSTOM_OH_MY_ZSH"; then
    if [ -f "./oh-my-zsh/my_setup.zsh" ] && [ -z "${CUSTOM_OH_MY_ZSH_SOURCE:-}" ]; then
      CUSTOM_OH_MY_ZSH_SOURCE="./oh-my-zsh/my_setup.zsh"
    fi
    if [ -f "./oh-my-zsh/themes/my_setup.zsh-theme" ] && [ -z "${CUSTOM_OH_MY_ZSH_THEME_SOURCE:-}" ]; then
      CUSTOM_OH_MY_ZSH_THEME_SOURCE="./oh-my-zsh/themes/my_setup.zsh-theme"
    fi
    install_custom_oh_my_zsh
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
