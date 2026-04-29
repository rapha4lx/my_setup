# my_setup

Bootstrap a new machine with `zsh`, Oh My Zsh, Docker, LazyDocker, OpenCode, and Oh My OpenAgent.

## Run from curl

Replace the URL with this repository's raw `install.sh` URL after pushing it to GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | sh
```

Optional variables:

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

1. Base packages: `zsh`, `curl`, `git`, `bash`, `ca-certificates`, `unzip`, and `tar`
2. Docker
3. LazyDocker
4. OpenCode
5. Bun / `bunx`
6. Oh My OpenAgent
7. Oh My Zsh
8. Default shell change to `zsh`

Supported package managers for base packages: `apt-get`, `dnf`, `yum`, `pacman`, `apk`, `zypper`, and `brew`.
