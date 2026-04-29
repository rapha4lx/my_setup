# my_setup

Bootstrap a new machine with `zsh`, Oh My Zsh, Docker, and LazyDocker.

## Run from curl

Replace the URL with this repository's raw `install.sh` URL after pushing it to GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/my_setup/main/install.sh | sh
```

Optional variables:

- `LAZYDOCKER_DIR`: LazyDocker install destination on Linux. Defaults to `$HOME/.local/bin`.

Supported package managers for base packages: `apt-get`, `dnf`, `yum`, `pacman`, `apk`, `zypper`, and `brew`.
