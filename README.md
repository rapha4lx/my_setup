# my_setup

Bootstrap a new machine with `zsh`, Oh My Zsh, Docker, LazyDocker, LazyVim, OpenCode, RTK, and Oh My OpenAgent.

## Run from curl

Replace the URL with this repository's raw `install.sh` URL after pushing it to GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | sh
```

The installer opens a checkbox menu when a TTY is available. Use arrow keys, `j/k`, or `w/s` to move, Space to toggle, and Enter to start installing.

To run with defaults and skip the menu:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | SETUP_MENU=never sh
```

Example disabling Docker:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | SETUP_MENU=never INSTALL_DOCKER=no sh
```

Optional variables:

- `SETUP_MENU`: Set to `never` to skip the terminal menu. Defaults to `auto`.
- `INSTALL_BASE`: Install base packages. Defaults to `yes`.
- `INSTALL_GH`: Install GitHub CLI. Defaults to `yes`.
- `INSTALL_DOCKER`: Install Docker. Defaults to `yes`.
- `INSTALL_LAZYDOCKER`: Install LazyDocker. Defaults to `yes`.
- `INSTALL_NODE20`: Install NVM and Node.js 20. Defaults to `yes`.
- `NODE_VERSION`: Node.js major/version installed through NVM. Defaults to `20`.
- `INSTALL_LAZYVIM_STACK`: Install Neovim, LazyVim starter, `tree-sitter` CLI, and run LazyVim sync. Defaults to `yes`.
- `NEOVIM_MIN_VERSION`: Minimum Neovim version required for LazyVim. Defaults to `0.11.2`.
- `INSTALL_OPENCODE`: Install OpenCode. Defaults to `yes`.
- `INSTALL_RTK`: Install RTK and configure it for OpenCode. Defaults to `yes`.
- `INSTALL_OH_MY_OPENAGENT`: Install Oh My OpenAgent. Defaults to `yes`.
- `INSTALL_OH_MY_ZSH`: Install Oh My Zsh. Defaults to `yes`.
- `INSTALL_CUSTOM_OH_MY_ZSH`: Install the custom Oh My Zsh file. Defaults to `yes`.
- `CONFIGURE_ZSHRC`: Configure `.zshrc` PATH and `EDITOR`. Defaults to `yes`.
- `SET_ZSH_DEFAULT`: Set `zsh` as the default shell. Defaults to `yes`.
- `CUSTOM_OH_MY_ZSH_SOURCE`: Source file or URL for the custom Oh My Zsh file. Defaults to this repo's raw `oh-my-zsh/my_setup.zsh`.
- `CUSTOM_OH_MY_ZSH_THEME_SOURCE`: Source file or URL for the custom Oh My Zsh theme. Defaults to this repo's raw `oh-my-zsh/themes/my_setup.zsh-theme`.
- `LAZYDOCKER_DIR`: LazyDocker install destination on Linux. Defaults to `$HOME/.local/bin`.
- `OMO_CLAUDE`: Claude subscription mode for Oh My OpenAgent. Use `no`, `yes`, or `max20`. Defaults to `no`.
- `OMO_OPENAI`: Enable OpenAI/ChatGPT subscription setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_GEMINI`: Enable Gemini setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_COPILOT`: Enable GitHub Copilot setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_OPENCODE_ZEN`: Enable OpenCode Zen setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_ZAI_CODING_PLAN`: Enable Z.ai Coding Plan setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_OPENCODE_GO`: Enable OpenCode Go setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_KIMI_FOR_CODING`: Enable Kimi for Coding setup for Oh My OpenAgent. Defaults to `no`.
- `OMO_VERCEL_AI_GATEWAY`: Enable Vercel AI Gateway setup for Oh My OpenAgent. Defaults to `no`.

Install order:

1. Base packages, including `zsh`, `curl`, `git`, `bash`, `ca-certificates`, `unzip`, `tar`, `neovim`, `ripgrep`, `fd`, `npm`/`node`, and a C compiler
2. GitHub CLI
3. Docker
4. LazyDocker
5. NVM and Node.js 20
6. LazyVim stack: Neovim, LazyVim starter, `tree-sitter` CLI, and plugin sync
7. OpenCode
8. RTK and OpenCode integration
9. Oh My OpenAgent, including Bun / `bunx`
10. Oh My Zsh
11. Custom Oh My Zsh file
12. `.zshrc` PATH and `EDITOR` setup
13. Default shell change to `zsh`

Supported package managers for base packages: `apt-get`, `dnf`, `yum`, `pacman`, `apk`, `zypper`, and `brew`.
