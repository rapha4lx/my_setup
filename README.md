# my_setup

Bootstrap a new machine with `zsh`, Oh My Zsh, Docker, LazyDocker, LazyVim, OpenCode, and Oh My OpenAgent.

## Run from curl

Replace the URL with this repository's raw `install.sh` URL after pushing it to GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | sh
```

The installer opens a terminal menu when a TTY is available. To run with defaults and skip the menu:

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
- `INSTALL_DOCKER`: Install Docker. Defaults to `yes`.
- `INSTALL_LAZYDOCKER`: Install LazyDocker. Defaults to `yes`.
- `INSTALL_LAZYVIM`: Install LazyVim starter. Defaults to `yes`.
- `INSTALL_OPENCODE`: Install OpenCode. Defaults to `yes`.
- `INSTALL_OH_MY_OPENAGENT`: Install Oh My OpenAgent. Defaults to `yes`.
- `INSTALL_OH_MY_ZSH`: Install Oh My Zsh. Defaults to `yes`.
- `CONFIGURE_ZSHRC`: Configure `.zshrc` PATH and `EDITOR`. Defaults to `yes`.
- `SET_ZSH_DEFAULT`: Set `zsh` as the default shell. Defaults to `yes`.
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

1. Base packages, including `zsh`, `curl`, `git`, `bash`, `ca-certificates`, `unzip`, `tar`, `neovim`, `ripgrep`, `fd`, and a C compiler
2. Docker
3. LazyDocker
4. LazyVim starter
5. OpenCode
6. Bun / `bunx`
7. Oh My OpenAgent
8. Oh My Zsh
9. Default shell change to `zsh`

Supported package managers for base packages: `apt-get`, `dnf`, `yum`, `pacman`, `apk`, `zypper`, and `brew`.
