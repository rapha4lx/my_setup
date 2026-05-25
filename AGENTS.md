# Repository Guidelines

## Project Structure & Module Organization
This repository is a small shell-based bootstrap setup.

- `install.sh`: main installer and interactive menu.
- `README.md`: usage, configuration flags, and install order.
- `oh-my-zsh/my_setup.zsh`: custom Oh My Zsh behavior and aliases.
- `oh-my-zsh/themes/my_setup.zsh-theme`: custom prompt theme.

Keep new setup logic in `install.sh` unless it is specific to Zsh runtime behavior, in which case place it under `oh-my-zsh/`.

## Build, Test, and Development Commands
There is no build system. Use shell checks and manual runs.

- `sh -n install.sh`: syntax check the installer.
- `shellcheck install.sh`: lint shell logic if available.
- `sh ./install.sh`: run locally from a checkout.
- `curl -fsSL <raw-install-url> | SETUP_MENU=never sh`: test the curl install path.

Prefer testing changes in a disposable VM or container when the script touches system packages.

## Coding Style & Naming Conventions
Use POSIX `sh` style with `set -eu`, two-space indentation inside functions, and simple helper functions for repeated logic.

- Use uppercase `INSTALL_*`, `OMO_*`, and similar environment flags.
- Use descriptive lowercase function names such as `install_opencode` or `configure_zshrc`.
- Keep logging consistent with `log`, `warn`, and `die`.
- Prefer ASCII-only text unless a file already uses Unicode, such as prompt symbols.

## Testing Guidelines
This repo does not have automated unit tests. Validation is mainly:

- shell syntax checks
- manual installer runs
- verifying menu labels and install order in `README.md`

When changing installation flow, confirm both interactive and `SETUP_MENU=never` paths still work.

## Commit & Pull Request Guidelines
Recent commits use short imperative summaries, for example: `Add GitHub CLI installer` or `Optimize zsh startup`.

- Keep commit messages concise and action-oriented.
- In pull requests, describe what changed, why it changed, and how you verified it.
- Mention any new environment variables or installation steps in `README.md`.

## Security & Configuration Notes
This script installs software and may modify the user’s shell and package manager state. Avoid hardcoding credentials, and document any new external downloads or default-on features clearly.
